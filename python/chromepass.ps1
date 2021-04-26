#Copyright (c) 2020,2021 Serguei Kouzmine
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.
#
# automate transfer the saved passwords from Chrome or Vivaldi (Windows)
# see also: WebBrowserPassView https://www.nirsoft.net/utils/web_browser_password.html
# see also: https://github.com/xorrior/RandomPS-Scripts/blob/master/Get-FoxDump.ps1 - invokes unmanaged code from nss3.dll to decrypt saved passwords in Mozilla
# and
# https://raw.githubusercontent.com/xorrior/RandomPS-Scripts/master/Get-ChromeDump.ps1
# https://habr.com/ru/company/vdsina/blog/518416/#habracut
# https://stackoverflow.com/questions/61099492/chrome-80-password-file-decryption-in-python
param (
  # several chromium based should be supported (verified with chrome and vivaldi)
  [String]$browser = 'chrome',
  [String]$url = $null,
  [String]$shared_assemblies_path = 'c:\java\selenium\csharp\sharedassemblies',
  [String]$backup = 'data.bak',
  [switch]$debug
)

# NOTE: slow
$has_tee_object = $false
$backup_filepath = ((get-location).path + '\' + $backup )
if (Get-Command 'tee-object' -CommandType Cmdlet -errorAction SilentlyContinue) {
  $has_tee_object = $true
  if (test-path -path $backup_filepath){
    clear-Content -path $backup_filepath -force
  }
}

# https://www.pinvoke.net/default.aspx/crypt32.cryptprotectdata
# https://stackoverflow.com/questions/14668143/cryptunprotectdata-returns-false-when-using-jni
# https://www.codota.com/code/java/methods/com.sun.jna.platform.win32.Crypt32/CryptUnprotectData
# https://java-native-access.github.io/jna/4.2.0/com/sun/jna/platform/win32/Crypt32Util.html
# http://javadox.com/net.java.dev.jna/jna/3.5.2/index-all.html
# https://coderoad.ru/43008556/Java-CryptUnprotectData-Windows-WiFi-пароли
<#
@'

[DllImport("Crypt32.dll",SetLastError=true,  CharSet=System.Runtime.InteropServices.CharSet.Auto)]
[return: MarshalAs(UnmanagedType.Bool)]
private static extern bool CryptUnprotectData(
    ref DATA_BLOB pDataIn,
    StringBuilder szDataDescr,
    String szDataDescr,
    ref DATA_BLOB pOptionalEntropy,
    IntPtr pvReserved,
    ref CRYPTPROTECT_PROMPTSTRUCT pPromptStruct,
    CryptProtectFlags dwFlags,
    ref DATA_BLOB pDataOut
);
'@

@'
[DllImport("Crypt32.dll", SetLastError=true,CharSet=System.Runtime.InteropServices.CharSet.Auto)]
[return: MarshalAs(UnmanagedType.Bool)]
private static extern bool CryptProtectData(
    ref DATA_BLOB pDataIn,
    String szDataDescr,
    ref DATA_BLOB pOptionalEntropy,
    IntPtr pvReserved,
    ref CRYPTPROTECT_PROMPTSTRUCT pPromptStruct,
    CryptProtectFlags dwFlags,
    ref DATA_BLOB pDataOut
);

'@
#>


# see also: https://blag.nullteilerfrei.de/2018/01/05/powershell-dpapi-script/
<#
param(
  [string] $StoreSecret,
  [Parameter(Mandatory=$True,Position=0)]
  [string] $filename )
[void] [Reflection.Assembly]::LoadWithPartialName("System.Security")
$scope = [System.Security.Cryptography.DataProtectionScope]::CurrentUser
if ($StoreSecret -eq "") {
  $data = Get-Content $filename
  $ciphertext = [System.Convert]::FromBase64String($data)
  # https://github.com/PowerShell/PowerShell/blob/master/src/System.Management.Automation/security/SecureStringHelper.cs#L519

  # internally calls CryptUnprotectData
  #
  # uint dwFlags = CAPI.CRYPTPROTECT_UI_FORBIDDEN;
  # if (scope == DataProtectionScope.LocalMachine) { dwFlags |= CAPI.CRYPTPROTECT_LOCAL_MACHINE; }
  # CyptUnprotectData( pDataIn: new IntPtr(&dataIn), ppszDataDescr: IntPtr.Zero, pO: new IntPtr(&entropy), pvReserved: IntPtr.Zero, pPromptStruct: IntPtr.Zero, dwFlags: dwFlags, pDataBlob: new IntPtr(&userData)))
  $plaintext = [System.Security.Cryptography.ProtectedData]::Unprotect( $ciphertext, $null, $scope )
  [System.Text.UTF8Encoding]::UTF8.GetString($plaintext)
} else {
  $plaintext = [System.Text.UTF8Encoding]::UTF8.GetBytes($StoreSecret)
  $ciphertext = [System.Security.Cryptography.ProtectedData]::Protect( $plaintext, $null, $scope )
  [System.Convert]::ToBase64String($ciphertext) > $filename
}
#>

$shared_assemblies = @(
  'System.Data.SQLite.dll', # NOTE: 'SQLite.Interop.dll' must be there too
  'nunit.framework.dll'
)
# new-object : Exception calling ".ctor" with "1" argument(s): 
# "An attempt was made to load a program with an incorrect format. 
# (Exception from HRESULT: 0x8007007E)
# Need a x86 or x64 package named System.Data.SQLite.x86 
# or System.Data.SQLite.x64
# and a matchig interop:
# https://www.nuget.org/api/v2/package/SQLite.Interop/1.0.0 for x86
# https://www.nuget.org/api/v2/package/SQLite.Interop.dll/1.0.103 for x64
# https://stackoverflow.com/questions/1001404/check-if-unmanaged-dll-is-32-bit-or-64-bit
# https://stackoverflow.com/questions/197951/how-can-i-determine-for-which-platform-an-executable-is-compiled

# SHARED_ASSEMBLIES_PATH environment overrides parameter
if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
}

pushd $shared_assemblies_path

$shared_assemblies | foreach-object {
  $shared_assembly_filename = $_
  add-Type -Path $shared_assembly_filename
}
popd
if ($browser -eq 'vivaldi') {
  $appdata_path = ('C:\Users\{0}\AppData\Local\Vivaldi\User Data\Default' -f $env:username)
} else {
  # the password_value setting stored in this file are no longer decryptable through
  $appdata_path = ('C:\Users\{0}\AppData\Local\Google\Chrome\User Data\Default' -f $env:username)
}
# TODO
$local_state_file = $env:USERPROFILE + '\AppData\Local\Google\Chrome\User Data\Local State'
write-output ('Reading {0}' -f $local_state_file )
$local_state = get-content -literalpath $local_state_file -encoding utf8
$local_state | out-file 'a.j.json' -encoding utf8
# $local_state = select-string -literalpath $local_state_file -encoding utf8 -pattern '.*'
try {
  $local_state_object = convertfrom-json -inputobject $local_state
} catch [Exception] {
  # convertfrom-json : Cannot process argument because the value of argument "name" is not valid. 
  # Change the value of the "name" argument and run the
  
}
# jq:
# parse error: Invalid numeric literal at line 1, column 3: wrong encoding
# c:\tools\jq-win64.exe -cr '.os_crypt.encrypted_key' a.j.json - get the key
$encrypted_key = '...'
$scope = [System.Security.Cryptography.DataProtectionScope]::CurrentUser
$optional_entropy = [Byte[]]@()
[void]($plain_key = [System.Security.Cryptography.ProtectedData]::Unprotect( [System.Convert]::FromBase64Stng($encrypted_key), $optional_entropy, $scope ))
# Exception calling "Unprotect" with "3" argument(s): "Unable to update the password. The value provided for the new password does not meet the length,complexity, or history requirements of the domain.

<#
{
    "app_list": {
        "app_launch_count": 0,
        "last_app_launch_ping": "13113792000000000",
        "last_launch_ping": "13113792000000000",
        "launch_count": 0
    },
    "autofill": {
        "states_data_dir": "C:\\Users\\Serguei\\AppData\\Local\\Google\\Chrome\\User Data\\AutofillStates\\2020.11.2.164946"
    },
    "browser": {
        "hung_plugin_detect_freq": 2000,
        "last_redirect_origin": "",
        "plugin_message_response_timeout": 25000,
        "shortcut_migration_version": "86.0.4240.75"
    },
    "data_use_measurement": {
        "data_used": {
            "services": {
                "background": {},
                "foreground": {}
            },
            "user": {
                "background": {},
                "foreground": {}
            }
        }
    },
    "easy_unlock": {
        "device_id": "a3f5d92f-0bcd-48f9-9226-bf244074ea9d",
        "user_prefs": {
            "": {
                "easy_unlock.proximity_required": false
            }
        }
    },
    "geolocation": {
        "access_token": {}
    },
    "hardware_acceleration_mode_previous": true,
    "intl": {
        "app_locale": "en"
    },
    "legacy": {
        "profile": {
            "name": {
                "migrated": true
            }
        }
    },
    "network_time": {
        "network_time_mapping": {
            "local": 1.619424721092101e+12,
            "network": 1.619410323e+12,
            "ticks": 44492654173.0,
            "uncertainty": 1222018.0
        }
    },
    "origin_trials": {
        "disabled_features": ["SecurePaymentConfirmation"]
    },
    "os_crypt": {
        "encrypted_key": "data"
    },
    "password_manager": {
        "os_password_blank": false,
        "os_password_last_changed": "13082591222457551"
    },
    "plugins": {
        "metadata": {
            "adobe-flash-player": {
                "displayurl": true,
                "group_name_matcher": "*Shockwave Flash*",
                "help_url": "https://support.google.com/chrome/?p=plugin_flash",
                "lang": "en-US",
                "mime_types": ["application/futuresplash", "application/x-shockwave-flash"],
                "name": "Adobe Flash Player",
                "url": "https://www.adobe.com/products/flashplayer/end-of-life.html",
                "versions": [{
                    "reference": "https://www.adobe.com/products/flashplayer/end-of-life.html",
                    "status": "requires_authorization",
                    "version": "32.0.0.466"
                }]
            },
            "chromium-pdf": {
                "group_name_matcher": "*Chromium PDF Viewer*",
                "mime_types": [],
                "name": "Chromium PDF Viewer",
                "versions": [{
                    "comment": "Chromium PDF Viewer has no version information.",
                    "status": "fully_trusted",
                    "version": "0"
                }]
            },
            "chromium-pdf-plugin": {
                "group_name_matcher": "*Chromium PDF Plugin*",
                "mime_types": [],
                "name": "Chromium PDF Plugin",
                "versions": [{
                    "comment": "Chromium PDF Plugin has no version information.",
                    "status": "fully_trusted",
                    "version": "0"
                }]
            },
            "google-chrome-pdf": {
                "group_name_matcher": "*Chrome PDF Viewer*",
                "mime_types": [],
                "name": "Chrome PDF Viewer",
                "versions": [{
                    "comment": "Google Chrome PDF Viewer has no version information.",
                    "status": "fully_trusted",
                    "version": "0"
                }]
            },
            "google-chrome-pdf-plugin": {
                "group_name_matcher": "*Chrome PDF Plugin*",
                "mime_types": [],
                "name": "Chrome PDF Plugin",
                "versions": [{
                    "comment": "Google Chrome PDF Plugin has no version information.",
                    "status": "fully_trusted",
                    "version": "0"
                }]
            },
            "x-version": 62
        },
        "resource_cache_update": "1619405261.789657"
    },
    "policy": {
        "last_statistics_update": "13263878800213175"
    },
    "profile": {
        "info_cache": {
            "Default": {
                "account_categories": 0,
                "active_time": 1619404931.171437,
                "avatar_icon": "chrome://theme/IDR_PROFILE_AVATAR_26",
                "background_apps": false,
                "first_account_name_hash": 569,
                "gaia_given_name": "",
                "gaia_id": "",
                "gaia_name": "",
                "gaia_picture_file_name": "",
                "has_multiple_account_names": true,
                "hosted_domain": "",
                "is_consented_primary_account": false,
                "is_ephemeral": false,
                "is_using_default_avatar": true,
                "is_using_default_name": true,
                "last_downloaded_gaia_picture_url_with_size": "",
                "local_auth_credentials": "",
                "managed_user_id": "",
                "metrics_bucket_index": 1,
                "name": "Person 1",
                "shortcut_name": "Person 1",
                "user_name": ""
            }
        },
        "last_active_profiles": ["Default"],
        "last_used": "Default",
        "metrics": {
            "next_bucket_index": 2
        },
        "profile_counts_reported": "13263878800169020"
    },
    "profile_network_context_service": {
        "http_cache_finch_experiment_groups": "Enabled_20210315_70p None None"
    },
    "session_id_generator_last_value": "466273937",
    "shutdown": {
        "num_processes": 0,
        "num_processes_slow": 0,
        "type": 0
    },
    "software_reporter": {
        "last_exit_code": 2,
        "last_time_sent_report": "13263706010187300",
        "last_time_triggered": "13263791243434948"
    },
    "subresource_filter": {
        "ruleset_version": {
            "checksum": 1701331079,
            "content": "9.22.0",
            "format": 28
        }
    },
    "supervised_users": {
        "whitelists": {}
    },
    "tab_stats": {
        "last_daily_sample": "13263891120924770",
        "max_tabs_per_window": 1,
        "total_tab_count_max": 1,
        "window_count_max": 1
    },
    "task_manager": {
        "column_visibility": {
            "IDS_TASK_MANAGER_CPU_COLUMN": true,
            "IDS_TASK_MANAGER_CPU_TIME_COLUMN": false,
            "IDS_TASK_MANAGER_GDI_HANDLES_COLUMN": false,
            "IDS_TASK_MANAGER_IDLE_WAKEUPS_COLUMN": false,
            "IDS_TASK_MANAGER_JAVASCRIPT_MEMORY_ALLOCATED_COLUMN": false,
            "IDS_TASK_MANAGER_KEEPALIVE_COUNT_COLUMN": false,
            "IDS_TASK_MANAGER_MEMORY_STATE_COLUMN": false,
            "IDS_TASK_MANAGER_NACL_DEBUG_STUB_PORT_COLUMN": false,
            "IDS_TASK_MANAGER_NET_COLUMN": true,
            "IDS_TASK_MANAGER_PHYSICAL_MEM_COLUMN": true,
            "IDS_TASK_MANAGER_PRIVATE_MEM_COLUMN": false,
            "IDS_TASK_MANAGER_PROCESS_ID_COLUMN": true,
            "IDS_TASK_MANAGER_PROCESS_PRIORITY_COLUMN": false,
            "IDS_TASK_MANAGER_PROFILE_NAME_COLUMN": false,
            "IDS_TASK_MANAGER_SHARED_MEM_COLUMN": false,
            "IDS_TASK_MANAGER_SQLITE_MEMORY_USED_COLUMN": false,
            "IDS_TASK_MANAGER_START_TIME_COLUMN": false,
            "IDS_TASK_MANAGER_TASK_COLUMN": true,
            "IDS_TASK_MANAGER_USER_HANDLES_COLUMN": false,
            "IDS_TASK_MANAGER_VIDEO_MEMORY_COLUMN": false,
            "IDS_TASK_MANAGER_WEBCORE_CSS_CACHE_COLUMN": false,
            "IDS_TASK_MANAGER_WEBCORE_IMAGE_CACHE_COLUMN": false,
            "IDS_TASK_MANAGER_WEBCORE_SCRIPTS_CACHE_COLUMN": false,
            "sort_column_id": "IDS_TASK_MANAGER_CPU_COLUMN",
            "sort_is_ascending": false
        },
        "window_placement": {
            "bottom": 643,
            "left": 528,
            "maximized": false,
            "right": 1256,
            "top": 229,
            "work_area_bottom": 826,
            "work_area_left": 0,
            "work_area_right": 1536,
            "work_area_top": 0
        }
    },
    "ukm": {
        "persisted_logs": []
    },
    "uninstall_metrics": {
        "installation_date2": "1438128296",
        "launch_count": "1955",
        "page_load_count": "12174",
        "uptime_sec": "386171"
    },
    "updateclientdata": {
        "apps": {
            "aemomkdncapdnfajjbbcbdebjljbpmpj": {
                "cohort": "1::",
                "cohortname": "",
                "dlrc": 5228,
                "pf": "96b188d6-8303-4c84-88c2-545961f77b4d"
            },
            "bcpgokokgekmnfkohklccmonnakdimfh": {
                "dlrc": 3589,
                "pf": "1bb6d297-9e25-47fb-8b27-1e6ebb763247"
            },
            "bklopemakmnopmghhmccadeonafabnal": {
                "cohort": "1:swl:",
                "cohorthint": "Auto",
                "cohortname": "Auto",
                "dlrc": 5224,
                "fp": "1.70497f45af368f6d591eb9b93a097b7b56821b0770ee00f04b2f5901487a0421",
                "pf": "fdff9a21-830b-4d62-af7d-2ea537718200",
                "pv": "4"
            },
            "cmahhnpholdijhjokonmfdjbfmklppij": {
                "cohort": "1:wr3:",
                "cohorthint": "Auto",
                "cohortname": "Auto",
                "dlrc": 5228,
                "fp": "1.b4ddbdce4f8d5c080328aa34c19cb533f2eedec580b5d97dc14f74935e4756b7",
                "pf": "54d4fe8c-160e-4722-8692-b55f11dd723e",
                "pv": "1.0.6"
            },
            "copjbmjbojbakpaedmpkhmiplmmehfck": {
                "cohort": "1:p1x:",
                "cohorthint": "Auto",
                "cohortname": "Auto",
                "dlrc": 4990,
                "pf": "d9198ea7-f4dc-4ddc-b4ee-30fe65443142"
            },
            "dfcoifdifjfolmglbbogapfcihdgckga": {
                "cohort": "1:v9l:",
                "cohorthint": "Auto",
                "cohortname": "Auto",
                "dlrc": 4990,
                "fp": "1.a842f56eaefb4e5b4e4b34fe001649e553ae413c84f62adda2f3ddf87a99496b",
                "pf": "8fcd82de-fa67-4dbe-9d7b-db96edc85817",
                "pv": "1"
            },
            "eeigpngbgcognadeebkilcpcaedhellh": {
                "cohort": "1:w59:",
                "cohorthint": "Auto",
                "cohortname": "Auto",
                "dlrc": 5228,
                "fp": "1.c64c9c1008f3ba5f6e18b3ca524bc98dcd8acfae0a2720a8f1f3ef0f8d643d05",
                "pf": "6e15479e-964f-4eaf-a2c7-d61a8ed29c11",
                "pv": "2020.11.2.164946"
            },
            "ehgidpndbllacpjalkiimkbadgjfnnmc": {
                "cohort": "1:ofl:",
                "cohorthint": "stable64",
                "cohortname": "stable64",
                "dlrc": 5228,
                "pf": "7a9aa6b0-a3a2-46e8-a342-a9575ef4fc3e"
            },
            "gcmjkmgdlgnkkcocmoeiminaijmmjnii": {
                "cohort": "1:bm1:",
                "cohorthint": "M54ToM99",
                "cohortname": "M54ToM99",
                "dlrc": 5228,
                "fp": "1.4dcc255c0d82123c9c4251bb453165672ea0458f0379f3a7a534dc2a666d7c6d",
                "pf": "5c2174fc-a340-4ea7-a4b3-f1d8d04094c3",
                "pv": "9.22.0"
            },
            "ggkkehgbnfjpeggfpleeakpidbkibbmn": {
                "cohort": "1:ut9:",
                "cohorthint": "M80ToM99",
                "cohortname": "M80ToM99",
                "dlrc": 5228,
                "fp": "1.6a4f38c608875324843b081607b4f9914988a3d87e2226d1ddc4e43d505078fb",
                "pf": "64b5529f-47ec-4371-a9c9-8d8e0baa3b7b",
                "pv": "2021.4.19.1142"
            },
            "giekcmmlnklenlaomppkphknjmnnpneh": {
                "cohort": "1:j5l:",
                "cohorthint": "Auto",
                "cohortname": "Auto",
                "dlrc": 5228,
                "pf": "ae427b7d-2725-4ed1-9ac8-3dd804cb9246"
            },
            "gkmgaooipdjhmangpemjhigmamcehddo": {
                "cohort": "1:pw3:",
                "cohorthint": "Stable",
                "cohortname": "Stable",
                "dlrc": 5228,
                "fp": "1.1b9bdd0e41bd6840742b0d38c95c810824ea4aea1092faeff13bde47e175b1e5",
                "pf": "df6c7d5b-36bf-495e-8ff8-9b88d223ab29",
                "pv": "89.259.200"
            },
            "hfnkpimlhhgieaddgfemjhofmfblmnib": {
                "cohort": "1:jcl:",
                "cohorthint": "Auto",
                "cohortname": "Auto",
                "dlrc": 5228,
                "fp": "1.efa6072fe25c259e51b2adb36e31ea00f21b15fdf64c728c952145757dae33e6",
                "pf": "928de9b9-77e1-425a-bfb2-09274999e83d",
                "pv": "6567"
            },
            "hnimpnehoodheedghdeeijklkeaacbdc": {
                "cohort": "1::",
                "cohortname": "",
                "dlrc": 5228,
                "pf": "74ca8757-ac9b-4771-8513-976c06eb4f82"
            },
            "ihnlcenocehgdaegdmhbidjhnhdchfmm": {
                "cohort": "1::",
                "cohorthint": "Auto",
                "cohortname": "",
                "dlrc": 5228,
                "pf": "53d9ef21-774b-47ab-ba56-ccce8841f52e"
            },
            "jamhcnnkihinmdlkakkaopbjbbcngflc": {
                "cohort": "1:wvr:",
                "cohorthint": "Auto",
                "cohortname": "Auto",
                "dlrc": 5228,
                "fp": "1.caff4d75fdb18bf98cc1e76857e7efba8c69d5ca7d7ced9ef6a92e9a993e6b77",
                "pf": "7ac7b451-d3e2-4f4b-b50f-8f9ebd59b522",
                "pv": "92.0.4487.0"
            },
            "jflookgnkcckhobaglndicnbbgbonegd": {
                "cohort": "1:s7x:",
                "cohorthint": "Auto",
                "cohortname": "Auto",
                "dlrc": 5228,
                "fp": "1.50d6038857beb1f5e459dc9a770a86e77b431241615a057d40efa17af32d3994",
                "pf": "c76840d2-946e-4653-9a22-31f5f3533d4d",
                "pv": "2621"
            },
            "kfoklmclfodeliojeaekpoflbkkhojea": {
                "cohort": "",
                "cohortname": "",
                "dlrc": 3750,
                "pf": "d778b39b-5955-4df7-9c38-8803483616b3"
            },
            "khaoiebndkojlmppeemjhbpbandiljpe": {
                "cohort": "1:cux:",
                "cohorthint": "Auto",
                "cohortname": "Auto",
                "dlrc": 5228,
                "fp": "1.ffd1d2d75a8183b0a1081bd03a7ce1d140fded7a9fb52cf3ae864cd4d408ceb4",
                "pf": "de7cacb7-7b6b-4642-bbfa-7fcd8b21c9ca",
                "pv": "43"
            },
            "llkgjffcdpffmhiakmfcdcblohccpfmo": {
                "cohort": "1::",
                "cohortname": "",
                "dlrc": 5228,
                "fp": "1.d730fdd6875bfda19ae43c639e89fe6c24e48b53ec4f466b1d7de2001f97e03c",
                "pf": "138efec8-97a3-4890-a5e3-89f9d7145305",
                "pv": "1.0.0.6"
            },
            "mimojjlkmoijpicakmndhoigimigcmbb": {
                "cohort": "1:xul:",
                "cohorthint": "Everyone",
                "cohortname": "Everyone",
                "dlrc": 5135,
                "fp": "1.e2eea62836472b37bb838870cbf87fe4139c5386c373cf306d376ec8f1c477da",
                "pf": "6589973d-07eb-4c6e-b7f6-45713211d1e2",
                "pv": "32.0.0.465"
            },
            "nhfgdggnnopgbfdlpeoalgcjdgfafocg": {
                "cohort": "1:fm9:",
                "cohortname": "Auto",
                "dlrc": 3776,
                "pf": "f2bb8662-3944-4471-91cc-1484633d2a17"
            },
            "npdjjkjlcidkjlamlmmdelcjbcpdjocm": {
                "cohort": "",
                "cohortname": "",
                "dlrc": 4460,
                "pf": "93c71cf7-2288-4f09-b27c-d67389fefd0e"
            },
            "oafdbfcohdcjandcenmccfopbeklnicp": {
                "cohort": "",
                "cohortname": "",
                "dlrc": 3900,
                "pf": "60273973-70ec-4222-bdc6-fecfd33c0283"
            },
            "obedbbhbpmojnkanicioggnmelmoomoc": {
                "cohort": "1:s6f:",
                "cohorthint": "Auto",
                "cohortname": "Auto",
                "dlrc": 5228,
                "fp": "1.0024f5c027ec6414971b6fa470de15f5cb32d10f1e864cb5a200e48e92462a98",
                "pf": "f5bafe4e-90e6-4d2b-9c7a-9fe8d34d543c",
                "pv": "20210417.369646782"
            },
            "oimompecagnajdejgnnjijobebaeigek": {
                "cohort": "1::",
                "cohortname": "",
                "dlrc": 5228,
                "pf": "20580e69-9b8c-4efa-83a5-a51e3695f7b0"
            },
            "ojhpjlocmbogdgmfpkhlaaeamibhnphh": {
                "cohort": "1:w0x:",
                "cohorthint": "Auto",
                "cohortname": "Auto",
                "dlrc": 5228,
                "fp": "1.478aa915e78878e332a0b4bb4d2a6fb67ff1c7f7b62fe906f47095ba5ae112d0",
                "pf": "862de3aa-3aa7-43b4-9b49-f18163635c37",
                "pv": "1"
            },
            "ojjgnpkioondelmggbekfhllhdaimnho": {
                "cohort": "1:0:",
                "cohorthint": "Auto",
                "cohortname": "Auto",
                "dlrc": 4599,
                "pf": "6b3921c2-a5ff-4012-bd8b-d0e39ddb2710"
            },
            "pdafiollngonhoadbmdoemagnfpdphbe": {
                "cohort": "1:vz3:",
                "cohorthint": "Auto",
                "cohortname": "Auto",
                "dlrc": 5228,
                "fp": "1.baeb7c645c7704139756b02bf2741430d94ea3835fb1de77fef1057d8c844655",
                "pf": "4603909c-3b03-4ddd-8af3-7fd5abf12365",
                "pv": "2021.2.22.1142"
            }
        }
    },
    "user_experience_metrics": {
        "client_id2": "C1D71A20-E296-455B-A88A-24E850F245A5",
        "client_id_timestamp": "1440601384",
        "initial_logs2": [{
            "data": "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",
            "hash": "V4zUPJOx9v27wmXSL14SB0JTX+8=",
            "signature": "epCKGwMWSiBXeRWH2y/0DMaTPTajH1va0i0V8c3ua+I=",
            "timestamp": "1554905368"
        }],
        "last_seen": {
            "CrashpadMetrics": "13199378860722451",
            "SetupMetrics": "13199378968394016"
        },
        "low_entropy_source2": 15,
        "low_entropy_source3": 6898,
        "machine_id": 3957322,
        "ongoing_logs2": [{
            "data": "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",
            "hash": "8U/AsN5OYeAuPMsIwieO7ujlBis=",
            "signature": "7X2sE/9Hs75IPoLCODdYBqACJ0DBi4U5ZFCfg4212XA=",
            "timestamp": "1554905367"
        }],
        "session_id": 2003,
        "stability": {
            "browser_last_live_timestamp": "13263898320063332",
            "child_process_crash_count": 0,
            "crash_count": 0,
            "deferred_count": 0,
            "discard_count": 48,
            "exited_cleanly": false,
            "extension_renderer_crash_count": 0,
            "extension_renderer_failed_launch_count": 0,
            "extension_renderer_launch_count": 55,
            "gpu_crash_count": 0,
            "incomplete_session_end_count": 0,
            "last_timestamp_sec": "1494025785",
            "launch_count": 10,
            "launch_time_sec": "1494025784",
            "page_load_count": 160,
            "plugin_stats2": [],
            "renderer_crash_count": 0,
            "renderer_failed_launch_count": 0,
            "renderer_hang_count": 0,
            "renderer_launch_count": 71,
            "session_end_completed": true,
            "stats_buildtime": "1618872235",
            "stats_version": "90.0.4430.85-64",
            "system_crash_count": 0,
            "version_mismatch_count": 0
        }
    },
    "variations_compressed_seed": "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",
    "variations_country": "us",
    "variations_crash_streak": 0,
    "variations_failed_to_fetch_seed_streak": 0,
    "variations_last_fetch_time": "13263898321147136",
    "variations_permanent_consistency_country": ["90.0.4430.85", "us"],
    "variations_safe_compressed_seed": "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",
    "variations_safe_seed_date": "13263841900000000",
    "variations_safe_seed_fetch_time": "13263880331515016",
    "variations_safe_seed_locale": "en-US",
    "variations_safe_seed_permanent_consistency_country": "us",
    "variations_safe_seed_session_consistency_country": "us",
    "variations_safe_seed_signature": "MEUCIQCcJHRuiKR8ZLnejtUF+9lxIZeAnlvT9SXbDv1RBfQ2OQIgETpzWlLmKBWb/Rp/XOrACoNBtIvG1uw8wBtNp6Xeyo8=",
    "variations_seed_date": "13263883923000000",
    "variations_seed_signature": "MEQCICLHf7TFmT3aHGR92UHVTC18mbh3ogvo9K3xBs+BjpiAAiBUeCUB7RKrwwwqcgKaTRHfDDNPZJqj/t87HqKKoBqKpg==",
    "was": {
        "restarted": false
    }
}
#>
$filename = 'Login Data'
$database = "${appdata_path}\${filename}"
$version = 3 # the only supported SQLite version at this time is 3
$connection_string = ('Data Source={0};Version={1};' -f $database,$version )
$connection = new-object System.Data.SQLite.SQLiteConnection ($connection_string)
if ($debug){
  write-output ('Opening {0}' -f $connection_string)
}
# TODO: check if browser is running
$connection.Open()
$datatSet = new-object System.Data.DataSet
$query = 'SELECT action_url, username_value, password_value FROM logins'
if ($url -ne $null) {
  $where = (" where action_url like '%{0}%'" -f $url )
} else { 
  $where = ''
}
$dataAdapter = new-object System.Data.SQLite.SQLiteDataAdapter ($query,$connection)
try {
  $dataAdapter.Fill($datatSet, 'passwords')
} catch [Exception] {
  if ($debug) {
    write-output $_.Exception.Message
  }
  if ($_.Exception.Message -match 'database is locked') {
    write-output ('you probably need to close the browser' -f $browser )
  }
}

$connection.Close()

[System.Collections.ArrayList]$result_array = @()
$result = new-object -typename psobject

if ($datatSet.Tables.Length -eq 1) {

  $rows = $datatSet.Tables['passwords'].Rows

  $rows | foreach-object {
    $row = $_

    if ($url -eq $null -or $row.action_url -match $url) {
      if ($debug) {
        $row | format-list
      }
      $result = new-object -typename psobject
      # https://www.gngrninja.com/script-ninja/2016/6/18/powershell-getting-started-part-12-creating-custom-objects
      add-member -inputobject $result -membertype NoteProperty -name url -value $row.action_url
      add-member -inputobject $result -membertype NoteProperty -name user -value $row.username_value
      $encrypted_data = $row.password_value
      [void] [Reflection.Assembly]::LoadWithPartialName('System.Security')
      $scope = [System.Security.Cryptography.DataProtectionScope]::CurrentUser
      $optional_entropy = [Byte[]]@()
      # optional additional byte array that was used to encrypt the data
      # https://docs.microsoft.com/en-us/dotnet/api/system.security.cryptography.protecteddata.unprotect?view=netframework-4.0
      # https://docs.microsoft.com/en-us/dotnet/api/system.security.cryptography.dataprotectionscope?view=netframework-4.0
      try {
        if ($debug) {
          write-output ('try to unprotect the encrypted data')
        }
        [void]($plaindata = [System.Security.Cryptography.ProtectedData]::Unprotect( $encrypted_data, $optional_entropy, $scope ))
        if ($debug) {
          write-output ('got plaindata')
        }
        # Unable to find type [System.Security.Cryptography.ProtectedData]. - this script should not be run as Administrator

        $plain_password_value = [System.Text.UTF8Encoding]::UTF8.GetString($plaindata)
        if ($debug) {
          write-output ('got plain password value')
        }
        add-member -inputobject $result -membertype NoteProperty -name password -value $plain_password_value
        if ($debug) {
          write-output $plain_password_value
        }
        $result_array.Add($result) | out-null
      } catch [Exception] {
        if ($debug) {
          # NOTE: issues with formatting
          # write-output ("Exception:`r`n{0} ...`r`n(ignored)" -f (($_.Exception.Message) -split "`r`n")[0])
          write-output ("Exception (ignored):`r`n{0}" -f $_.Exception.Message)
        }
      }
    }
  }
}
if ($has_tee_object) {
  # NOTE: bug? swapping the format-list with tee-object will make only first column of every $result row backed up into the file
  $result_array | where-object { $_.url -ne ''}  |format-list | tee-object -filepath $backup_filepath
} else {
  $result_array | where-object { $_.url -ne ''} | format-list
}


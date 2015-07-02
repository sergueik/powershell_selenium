[void][Reflection.Assembly]::LoadWithPartialName("Microsoft.Web.Administration")

$iis = New-Object Microsoft.Web.Administration.ServerManager
$iisStatus = Get-WmiObject Win32_Service -Filter "Name = 'IISADMIN'"
$server = @()
$sites = @()

 $iis.sites | foreach-object { $site = $_
  $applications = @()

$site.Applications | foreach-object { $appPool  = $_
    $appPoolName = $appPool.ApplicationPoolName
    $apppoolobject = $iis.ApplicationPools[$appPoolName]
    $applications += @{
      'applicationName' = $appPool.Path;
      'applicationPool' = $appPool.ApplicationPoolName;
      'dotNetVersion' = $apppoolobject.ManagedRuntimeVersion;
      'status' = $apppoolobject.State;
      'mode' = $apppoolobject.ManagedPipelineMode;

    }

  }
$bindings = @()
$site.Bindings | foreach-object { $binding  = $_
    $bindings += @{ 
'Host' = $binding.Host;
'Protocol' = $binding.Protocol;
'EndPoint' = $binding.EndPoint;
'BindingInformation' = $binding.BindingInformation;

}
}
  $sites += @{
    'Id' = $site.Id;
    'Name' = $site.Name;
    'State' = $site.State;
    'Applications' = $applications;
  'Bindings' = $bindings;
  }
}

$server += @{

  'serverName' = $env:ComputerName;
  'iisStatus' = $iisStatus.State;
  'Sites' = $sites;

}

$server | ConvertTo-Json -Depth 10

<#
{
	{
		"Bindings": [{
			"Host": "",
			"Protocol": "http"
		}, {
			"Host": "",
			"Protocol": "https"
		}],
		"Applications": [{
			"status": 1,
			"dotNetVersion": "v4.0",
			"applicationName": "/",
			"applicationPool": "AUCore",
			"mode": 0
		}, {
			"status": 1,
			"dotNetVersion": "v4.0",
			"applicationName": "/DomainData",
			"applicationPool": "AUDomainData",
			"mode": 0
		}],
		"Name": "CarnivalAU",
		"Id": 3,
		"State": 1
	}]
}

#>

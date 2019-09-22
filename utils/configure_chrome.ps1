# based on: http://forum.oszone.net/thread-342256.html
param(
  [String]$downoad = "${env:USERPROFILE}\Downloads", # no configuration default
  [switch]$all
)

$po_filepath = "${env:LocalAppData}\Google\Chrome\User Data\Default\Preferences"
$po = get-content -Path $po_filepath | convertfrom-json
# $po is a System.Management.Automation.PSCustomObject
# its fields are accessed through getters and setters

# TODO: handle 'null' 
if(-not $po.download.default_directory) {
  add-member -inputObject $po.download -NotePropertyName 'default_directory' -NotePropertyValue $download
} else {
  $po.download.default_directory = $download
}
if(-not $po.savefile.default_directory) {
  add-member -inputObject $po.savefile -NotePropertyName 'default_directory' -NotePropertyValue $download
} else {
  $po.savefile.default_directory = $download
}

convertto-json -InputObject $po -Compress -Depth 10 | set-content -Path $po_filepath

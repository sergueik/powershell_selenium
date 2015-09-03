# origin: http://poshcode.org/5679 for additional registry hack

$schemas = @(
  'http',
  'https',
  'ftp'
)
$browsers = @{
  'FirefoxURL' = 'Firefox';
  'Opera\.Protocol' = 'Opera';
  'ChromeHTML' = 'Chrome';
  'IE\..*' = 'Interner Explorer';
}
pushd 'HKCU:'
cd '/Software/Microsoft/Windows/Shell/Associations/UrlAssociations'
$schemas | ForEach-Object {
  $schema = $_
  pushd $schema
  $x = Get-ItemProperty -Path 'UserChoice' -Name 'Progid'
  $handler = $x.'Progid'
  $browsers.Keys | ForEach-Object {
    if ($handler -match $_) {
      write-host ('{0} is the default for {1}' -f $browsers[$_], $schema)
    }
  }
  popd
}
popd

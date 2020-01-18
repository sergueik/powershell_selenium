$MODULE_NAME = 'src/Monocle.psm1'

$module_path = Split-Path -Parent -Path (Split-Path -Parent -Path $MyInvocation.MyCommand.Path)
Import-Module -Name ('{0}/{1}' -f $module_path,$MODULE_NAME) -Force -ErrorAction Stop
# Create a browser object
$browser = New-MonocleBrowser -Type Chrome

# Monocle runs commands in web flows, for easy disposal and test tracking
# Each flow needs a name
Start-MonocleFlow -Name 'Load YouTube' -Browser $browser -ScriptBlock {

    # Tell the browser which URL to navigate to, will sleep while page is loading
    Set-MonocleUrl -Url 'https://www.ya.ru'
Start-MonocleSleepUntilPresentElement
} -CloseBrowser -ScreenshotOnFail

# or close the browser manually:
#Close-MonocleBrowser -Browser $browser

function Start-MonocleSleep
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [int]
        $Seconds
    )

    Write-MonocleHost -Message "Sleeping for $Seconds second(s)"
    Start-Sleep -Seconds $Seconds
}

function Invoke-MonocleScreenshot
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $Name,

        [string]
        $Path
    )

    $screenshot = $Browser.GetScreenshot()

    if ([string]::IsNullOrWhiteSpace($Path)) {
        $Path = $pwd
    }

    $Name = ($Name -replace ' ', '_')
    $filepath = Join-Path $Path "$($Name).png"
    $screenshot.SaveAsFile($filepath, [OpenQA.Selenium.ScreenshotImageFormat]::Png)

    Write-MonocleHost -Message "Screenshot saved to: $filepath"
    return $filepath
}

function Save-MonocleImage
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [OpenQA.Selenium.IWebElement]
        $Element,

        [Parameter(Mandatory=$true)]
        [string]
        $FilePath
    )

    # get the meta id of the element
    $id = Get-MonocleElementId -Element $Element
    Write-MonocleHost -Message "Downloading image from $($id)"

    $tag = $Element.TagName
    if (@('img', 'image') -inotcontains $tag) {
        throw "Element $($id) is not an image element: $tag"
    }

    $src = Get-MonocleElementAttribute -Element $Element -Name 'src'
    if ([string]::IsNullOrWhiteSpace($src)) {
        throw "Element $($id) has no src attribute"
    }

    Invoke-MonocleDownloadImage -Source $src -Path $FilePath
}

function Restart-MonocleBrowser
{
    [CmdletBinding()]
    param ()

    Write-MonocleHost -Message "Refreshing the Browser"
    $Browser.Navigate().Refresh()
    Start-MonocleSleepWhileBusy
    Start-Sleep -Seconds 2
}

function Get-MonocleHtml
{
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $FilePath
    )

    $content = $Browser.PageSource

    if ([string]::IsNullOrWhiteSpace($FilePath)) {
        Write-MonocleHost -Message "Retrieving the current page's HTML content"
        return $content
    }

    Write-MonocleHost -Message "Writing the current page's HTML to '$($FilePath)'"
    $content | Out-File -FilePath $FilePath -Force | Out-Null
}

function Start-MonocleSleepUntilPresentElement
{
    [CmdletBinding()]
    param (
      [String]$selector = 'text'
    )

    $count = 0
    $timeout = Get-MonocleTimeout

    $script = @'

// Wait block
var _await = function(_selector){
    var element= document.getElementById(_selector);
    if (typeof element== 'undefined' || element== null){
        setTimeout(function() {
            _await(_selector);
        }, 1000);
    }
}
var _selector = arguments[0];
_await(_selector);
// Exception calling "ExecuteScript" with "2" argument(s): "javascript error: Unexpected reserved word
return(true);
'@    
    Invoke-MonocleJavaScript -Script $script -arguments @($selector)
    # TODO: meaningful message
    # Write-MonocleHost -Message "Browser busy for $count seconds(s)"
}


function Invoke-MonocleJavaScript
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]
        $Script,

        [Parameter()]
        [object[]]
        $Arguments
    )

    $Browser.ExecuteScript($Script, $Arguments)
}

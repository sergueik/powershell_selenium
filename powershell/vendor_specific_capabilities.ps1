#Copyright (c) 2015 Serguei Kouzmine
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

# https://github.com/saucelabs/sauce-dotnet-examples/
function AdddLoadCapabilities (
  [string]$title

) {


  $MODULE_NAME = 'selenium_utils.psd1'
  Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)

  @( 'System.Drawing','System.Windows.Forms') | ForEach-Object { [void][System.Reflection.Assembly]::LoadWithPartialName($_) }
  $f = New-Object System.Windows.Forms.Form
  $f.Text = $title

  $panel2 = New-Object System.Windows.Forms.TabPage
  $tb1 = New-Object System.Windows.Forms.TextBox
  $panel1 = New-Object System.Windows.Forms.TabPage
  $panel1.Text = "Add Capabilities"
  $button1 = New-Object System.Windows.Forms.Button
  $tbc1 = New-Object System.Windows.Forms.TabControl
  $panel2.SuspendLayout()
  $panel1.SuspendLayout()
  $tbc1.SuspendLayout()
  $f.SuspendLayout()

  $tb1.Location = New-Object System.Drawing.Point (72,7)
  $tb1.Name = "textBoxMessage"
  $tb1.Size = New-Object System.Drawing.Size (200,20)
  $tb1.TabIndex = 0

  $l1 = New-Object System.Windows.Forms.Label
  $l1.Location = New-Object System.Drawing.Size (202,32)
  $l1.Size = New-Object System.Drawing.Size (140,16)
  $hub_host = '127.0.0.1'
  $hub_port = '4444'

  $l1.Text = ''

  $l1.Font = New-Object System.Drawing.Font ('Microsoft Sans Serif',8,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,0);
  $panel2.Controls.Add($l1)
  $tb1.Text = ('http://{0}:{1}/wd/hub' -f $hub_host,$hub_port)
  $uri = [System.Uri]($tb1.Text)


  $tb1.Add_Leave({
      param(
        [object]$sender,
        [System.EventArgs]$eventargs
      )
      if ($sender.Text.Length -eq 0) {
        $l1.Text = 'Input required'
        # [System.Windows.Forms.MessageBox]::Show('Input required') 
        $tbc1.SelectedIndex = 1
        $sender.Select()
        $result = $sender.Focus()
      } else {
        $l1.Text = ''
      }
    })


  $button1 = New-Object System.Windows.Forms.Button

  $button1.Location = New-Object System.Drawing.Point (297,7)
  $button1.Name = "buttonShowMessage"
  $button1.Size = New-Object System.Drawing.Size (107,24)
  $button1.TabIndex = 0
  $button1.Text = 'Test Connection'
  $button1_Click = {
    param(
      [object]$sender,
      [System.EventArgs]$eventargs
    )


    $selenium = $null
    $browser = 'chrome'
    $version = '43'
    $version = '35'

    $platform = 'windows'
    $platform = 'linux'

    $username = 'kouzmine_serguei'
    $access_key = 'fbd94661-d447-4d16-bdb8-5317fe264604'
    $platforms = @{
      'windows' = [OpenQA.Selenium.PlatformType]::Windows;
      'mac' = [OpenQA.Selenium.PlatformType]::Mac;
      'linux' = [OpenQA.Selenium.PlatformType]::Linux;

    }


    load_shared_assemblies


    [OpenQA.Selenium.Remote.DesiredCapabilities]$capabillities = New-Object OpenQA.Selenium.Remote.DesiredCapabilities ($browser,$version,[OpenQA.Selenium.Platform]::CurrentPlatform)
    # wrong  argument
    #    $capabillities.SetCapability("platform",$platforms[$platform])
    $capabillities.SetCapability("platform",$platform)

    $capabillities.SetCapability("username",$username)
    $capabillities.SetCapability("accessKey",$access_key)
    $capabillities.SetCapability("name","Test_Name")
    # start a new remote web driver session on sauce labs
    $uri = $tb1.Text
    [System.Windows.Forms.MessageBox]::Show($uri);
    $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri,$capabillities)

    $explicit = 30
    [void]($selenium.Manage().timeouts().ImplicitlyWait([System.TimeSpan]::FromSeconds($explicit)))

    $base_url = "https://saucelabs.com/test/guinea-pig"
    $selenium.Navigate().GoToUrl($base_url)
    Write-Host "https://www.whatismybrowser.com/"
    $selenium.Navigate().GoToUrl("https://www.whatismybrowser.com/")


    [OpenQA.Selenium.Screenshot]$screenshot = $selenium.GetScreenshot()
    $filename = 'test'
    $screenshot_path = (Get-ScriptDirectory)
    Write-Host ([System.IO.Path]::Combine($screenshot_path,('{0}.{1}' -f $filename,'png')))
    $screenshot.SaveAsFile([System.IO.Path]::Combine($screenshot_path,('{0}.{1}' -f $filename,'png')),[System.Drawing.Imaging.ImageFormat]::Png)
    Write-Host 'saved'
    $caller.Message = $tb1.Text

  }
  $button1.add_click($button1_Click)
  $panel2.Controls.Add($button1)

  $panel2.Controls.Add($tb1)
  $panel2.Location = New-Object System.Drawing.Point (4,22)
  $panel2.Name = "tabPage2"
  $panel2.Padding = New-Object System.Windows.Forms.Padding (3)
  $panel2.Size = New-Object System.Drawing.Size (509,202)
  $panel2.TabIndex = 1
  $panel2.Text = "Load Capabilities"

  $grid = New-Object System.Windows.Forms.DataGridView
  $grid.AutoSize = $true
  $grid.DataBindings.DefaultDataSourceUpdateMode = 0
  $grid.Name = 'dataGrid1'
  $grid.DataMember = ''
  $grid.TabIndex = 0
  $grid.Location = New-Object System.Drawing.Point (13,50)
  $grid.Dock = [System.Windows.Forms.DockStyle]::Fill
  $grid.AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::AllCells
  $grid.ColumnCount = 2
  $grid.Columns[0].Name = 'Parameter Name'
  $grid.Columns[1].Name = 'Value'
  (0..2) | ForEach-Object {
    $row1 = @( '','')
    $grid.Rows.Add($row1)
  }

  $grid.Columns[0].ReadOnly = $false;

  foreach ($row in $grid.Rows) {
    $row.cells[0].Style.BackColor = [System.Drawing.Color]::LightGray
    $row.cells[0].Style.Font = New-Object System.Drawing.Font ('Microsoft Sans Serif',8.25)
    $row.cells[0].Style.ForeColor = [System.Drawing.Color]::White
    $row.cells[1].Style.Font = New-Object System.Drawing.Font ('Microsoft Sans Serif',8.25)
  }
  <#

http://www.howtogeek.com/howto/30014/run-ie6-and-other-old-apps-in-windows-7-with-spoon/

http://stackoverflow.com/questions/22010163/internet-explorer-versions-testing-in-february-2014-browserstack-saucelabs-gh
https://saucelabs.com/selenium?dmr=0801f3fc4276057257c2237525fc69da0a6063f5c14eb80155a27cd9

#>
  # http://www.seleniumhq.org/ecosystem/
  $configuration = @{
    'BrowserStack' =
    @{ 'capabilities' = @{
        'browserstack.user' = 'USERNAME';
        'browserstack.key' = 'ACCESS_KEY';
      };
      'hub_url' = 'http://hub.browserstack.com/wd/hub/';
      'help_url' = 'https://www.browserstack.com/automate/c-sharp#configure-capabilities';

    };

    'Sauce Labs' =
    @{ 'capabilities' = @{
        'username' = 'USERNAME';
        'accesskey' = 'ACCESS_KEY';
      };
      'hub_url' = 'http://ondemand.saucelabs.com:80/wd/hub';
      'help_url' = 'https://www.browserstack.com/automate/c-sharp#configure-capabilities';
      # http://YOUR_USERNAME:YOUR_ACCESS_KEY@ondemand.saucelabs.com:80/wd/hub
    };

    'TestingBot' =
    @{ 'capabilities' = @{
        'username' = $null;
        'accesskey' = $null;
      };
      'hub_url' = $null;
      'help_url' = 'https://testingbot.com/features';

    };

    # https://spoon.net/selenium

  }

  $cb1 = New-Object System.Windows.Forms.ComboBox
  $cb1.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
  $cb1.Dock = [System.Windows.Forms.DockStyle]::Bottom

  $cb1_SelectedIndexChanged = {
    param(
      [object]$sender,
      [System.EventArgs]$eventargs
    )

    $caller.Message = $sender.SelectedIndex.ToString()
    # [System.Windows.Forms.MessageBox]::Show($sender.Text)
    if ($sender.Text -match '\w+') {
      $tb1.Text = $configuration[$sender.Text]['hub_url']
      $capabilities = $configuration[$sender.Text]['capabilities']
      $grid.Rows.Clear()
      $capabilities.Keys | ForEach-Object {
        $row1 = @( $_,$capabilities[$_])
        $grid.Rows.Add($row1)
      }

    }

  }
  $cb1.add_SelectedIndexChanged($cb1_SelectedIndexChanged)

  $cb1.Location = New-Object System.Drawing.Size (10,40)
  $cb1.Size = New-Object System.Drawing.Size (260,20)
  $cb1.Height = 80


  [void]$cb1.Items.Add('Sauce Labs')
  [void]$cb1.Items.Add('BrowserStack')
  [void]$cb1.Items.Add('TestingBot')

  $panel1.Controls.Add($cb1)

  $panel1.Controls.Add($grid)
  $grid.ResumeLayout($false)

  $tbc1.Controls.Add($panel1)
  $tbc1.Controls.Add($panel2)
  $tbc1.Location = New-Object System.Drawing.Point (13,13)
  $tbc1.Name = "tabControl1"
  $tbc1.SelectedIndex = 1
  $tb1.Select()
  $tb1.Enabled = $true
  $tbc1.Size = New-Object System.Drawing.Size (550,208)
  $tbc1.TabIndex = 0

  $f.AutoScaleBaseSize = New-Object System.Drawing.Size (5,13)
  $f.ClientSize = New-Object System.Drawing.Size (553,258)
  $f.Controls.Add($tbc1)
  $panel2.ResumeLayout($false)
  $panel2.PerformLayout()
  $panel1.ResumeLayout($false)
  $tbc1.ResumeLayout($false)
  $f.ResumeLayout($false)
  $f.ActiveControl = $tb1

  $f.Topmost = $true
  $f.Add_Shown({ $f.Activate() })
  $f.KeyPreview = $True
  [void]$f.ShowDialog([win32window]($caller))

  $f.Dispose()
}

Add-Type -TypeDefinition @"
// "
using System;
using System.Windows.Forms;
public class Win32Window : IWin32Window
{
    private IntPtr _hWnd;
    private int _data;
    private string _message;

    public int Data
    {
        get { return _data; }
        set { _data = value; }
    }
    public string Message
    {
        get { return _message; }
        set { _message = value; }
    }

    public Win32Window(IntPtr handle)
    {
        _hWnd = handle;
    }

    public IntPtr Handle
    {
        get { return _hWnd; }
    }
}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll'

$DebugPreference = 'Continue'
$title = 'Enter Message'
$caller = New-Object Win32Window -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess().MainWindowHandle)

AdddLoadCapabilities -Title $title -caller $caller
Write-Debug ("Message is : {0} " -f $caller.Message)

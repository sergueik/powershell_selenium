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


# http://seleniumeasy.com/selenium-tutorials/set-browser-width-and-height-in-selenium-webdriver

param(
  [string]$browser = 'firefox',
  [string]$base_url = 'http://stackoverflow.com',
  [int]$event_delay = 250,
  [switch]$grid,
  [switch]$debug,
  [switch]$pause
)

[bool]$fullstop = [bool]$PSBoundParameters['pause'].IsPresent

# origin : https://github.com/testingbot/Selenium-Screenshots
Add-Type -IgnoreWarnings -TypeDefinition @"

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Diagnostics;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Timers;
using System.Management;
using System.IO;

namespace ScreenShotter
{
    public class Program
    {

        private string _fileName;
        public string FileName
        {
            get { return _fileName; }
            set { _fileName = value; }
        }

        private int _processID;
        public int processID
        {
            get { return _processID; }
            set { _processID = value; }
        }

        public struct RECT
        {
            public int Left;
            public int Top;
            public int Right;
            public int Bottom;
        };

        private static int width;
        private static int height;

        private static int originalWidth;
        private static int originalHeight;

        private static Process observedProcess;
        [DllImport("user32.dll")]
        private static extern bool PrintWindow(IntPtr hwnd, IntPtr hdcBlt, uint nFlags);

        [DllImport("user32.dll")]
        private static extern int GetWindowText(IntPtr hWnd, StringBuilder text, int count);

        [DllImport("user32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        private static extern bool EnumThreadWindows(int threadId, EnumThreadProc pfnEnum, IntPtr lParam);

        private delegate bool EnumThreadProc(IntPtr hwnd, IntPtr lParam);

        private static IntPtr hwndProgram;
        public void Run()
        {

            try
            {
                Process p = Process.GetProcessById(processID);

                if (p == null)
                {
                    // could not fetch process info
                    Environment.Exit(0);
                }

                observedProcess = p;
                getWindowHandle();
            }
            catch (Exception e)
            {
                Console.WriteLine("Could not fetch process info");
                Environment.Exit(0);
            }

            Console.WriteLine("Screenshot saved");
            // Environment.Exit(0);
        }
        public void getWindowHandle()
        {
            // loop all windows for this process
            foreach (ProcessThread t in observedProcess.Threads)
            {
                EnumThreadWindows(t.Id, MyEnumThreadWindowsProc, IntPtr.Zero);
            }

            if (hwndProgram.ToInt32() == 0)
            {
                // could not find a window in the process that matches our requirements (Needs to be a valid browser window)
                Environment.Exit(0);
            }

            // we're ready to take a picture
            takeShot();
        }

        private void takeShot()
        {
            RECT srcRect;
            if (GetWindowRect(hwndProgram, out srcRect))
            {
                originalWidth = srcRect.Right - srcRect.Left;
                originalHeight = srcRect.Bottom - srcRect.Top;

                width = 400;
                height = (originalHeight / (originalWidth / width));

                if ((height % 2) != 0)
                {
                    height++;
                }


                Bitmap b = new Bitmap(originalWidth, originalHeight);

                using (Graphics g = Graphics.FromImage(b))
                {
                    IntPtr hdc = g.GetHdc();
                    bool result = PrintWindow((IntPtr)observedProcess.MainWindowHandle, hdc, 0);
                    g.ReleaseHdc();
                    g.Flush();
                }

                // Bitmap resized = ResizeImage(b, width, height);
                Console.WriteLine(String.Format("Saving to {0}", _fileName));
                b.Save(_fileName);
            }
        }

        private bool MyEnumThreadWindowsProc(IntPtr hWnd, IntPtr lParam)
        {
            if (hwndProgram.ToInt32() != 0)
            {
                return true;
            }
            StringBuilder buffer = new StringBuilder(256);
            if (GetWindowText(hWnd, buffer, buffer.Capacity) > 0)
            {
                Console.WriteLine(buffer.ToString());
                if ((buffer.ToString().IndexOf("Firefox") > -1) || (buffer.ToString().IndexOf("Internet Explorer") > -1) || (observedProcess.ProcessName == "Safari" && (buffer.ToString() != "Safari") && (buffer.ToString() != "MSCTFIME UI") && (buffer.ToString() != "Default IME") && (buffer.ToString() != "CoreAnimationTesterWindow") && (buffer.ToString().IndexOf("Selenium Remote Control") == -1) && (buffer.ToString().IndexOf("Untitled") == -1)))
                {
                    if ((buffer.ToString().IndexOf("Selenium Remote Control") == -1) && !buffer.ToString().Equals("Windows Internet Explorer") && !buffer.ToString().Equals("Mozilla Firefox") && (buffer.ToString().IndexOf("AppData") == -1))
                    {
                        hwndProgram = hWnd;
                    }
                }
            }
            return true;
        }

        public System.Drawing.Bitmap ResizeImage(Bitmap image, int width, int height)
        {
            //a holder for the result
            Bitmap result = new Bitmap(width, height);

            //use a graphics object to draw the resized image into the bitmap
            using (Graphics gg = Graphics.FromImage(result))
            {
                //draw the image into the target bitmap
                gg.DrawImage(image, 0, 0, width, height);
                gg.Dispose();
            }

            //return the resulting bitmap
            return result;
        }
    }
}

"@ -ReferencedAssemblies 'System.Windows.Forms.dll','System.Drawing.dll'



$MODULE_NAME = 'selenium_utils.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)
load_shared_assemblies

# http://stackoverflow.com/questions/10752512/get-pid-of-browser-launched-by-selenium
# http://stackoverflow.com/questions/18686474/find-pid-of-browser-process-launched-by-selenium-webdriver

$pids_before = @{}
$pids_after = @{}

Get-Process -Name $browser -ErrorAction 'silentlycontinue' | Select-Object -Property ID | ForEach-Object { $pids_before[$_.Id] = $null }
if ([bool]$PSBoundParameters['grid'].IsPresent) {
  $selenium = launch_selenium -browser $browser -grid
  Start-Sleep -Millisecond 5000
} else {
  $selenium = launch_selenium -browser $browser
}
Get-Process -Name $browser -ErrorAction 'silentlycontinue' | Select-Object -Property ID | ForEach-Object { $pids_after[$_.Id] = $null }

# write-host ("Pids after `r`n{0}" -f ($pids_after.Keys -join "`r`n"))
# write-host ("Pids before `r`n{0}" -f ($pids_before.Keys -join "`r`n"))

$pids = @()
$pids_after.Keys | ForEach-Object { if (-not $pids_before.ContainsKey($_)) { $pids += $_ } }
Write-Host ("Pids `r`n{0}" -f ($pids -join "`r`n"))
$o = New-Object -TypeName 'ScreenShotter.Program'
$o.ProcessID = $pids[$pids.Count - 1]
$o.FileName = 'C:\developer\sergueik\powershell_selenium\powershell\test.jpg'

[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
if ($host.Version.Major -le 2) {
  [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
  $selenium.Manage().Window.Size = New-Object System.Drawing.Size (600,400)
  $selenium.Manage().Window.Position = New-Object System.Drawing.Point (0,0)
} else {
  $selenium.Manage().Window.Size = @{ 'Height' = 400; 'Width' = 600; }
  $selenium.Manage().Window.Position = @{ 'X' = 0; 'Y' = 0 }
}

$window_position = $selenium.Manage().Window.Position
$window_size = $selenium.Manage().Window.Size

# https://github.com/yizeng/EventFiringWebDriverExamples
$event_firing_selenium = New-Object -Type 'OpenQA.Selenium.Support.Events.EventFiringWebDriver' -ArgumentList @( $selenium)

$exception_handler = $event_firing_selenium.add_ExceptionThrown
$exception_handler.Invoke({
    param(
      [object]$sender,
      [OpenQA.Selenium.Support.Events.WebDriverExceptionEventArgs]$eventargs
    )
    Write-Host 'Taking screenshot' -foreground 'Yellow'
    $filename = 'test'
    # Take screenshot identifying the browser
    [OpenQA.Selenium.Screenshot]$screenshot = $sender.GetScreenshot()
    $o.Run()
    $screenshot.SaveAsFile([System.IO.Path]::Combine((Get-ScriptDirectory),('{0}.{1}' -f $filename,'png')),[System.Drawing.Imaging.ImageFormat]::Png)
    # initiate browser close  event from the exception handler? 
  })
$event_firing_selenium.Navigate().GoToUrl($base_url)
$event_firing_selenium.Manage().Window.Maximize()

Start-Sleep -Millisecond 3000
$event_firing_selenium.FindElement([OpenQA.Selenium.By]::CssSelector("#hlogo > a")).Displayed
Start-Sleep -Millisecond 3000
$event_firing_selenium.FindElement([OpenQA.Selenium.By]::CssSelector("#hlogo > a > b > c")).Displayed

custom_pause -fullstop $fullstop
cleanup ([ref]$selenium)


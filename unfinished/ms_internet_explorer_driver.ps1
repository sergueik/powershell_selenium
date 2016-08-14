# cover:
# http://jimevansmusic.blogspot.com/2014/09/using-internet-explorer-webdriver.html
# http://msdn.microsoft.com/en-us/library/ie/dn725043%28v=vs.85%29.aspx

# IEDCWebDriver.dll - not found after installing KB2990999 - need a restart.
# and install of Internet Explorer Developer Channel for Windows 7 SP1 
# "c:\Program Files\Common Files\IEDCWebDriver\IEDCWebDriver.dll" 
# is native
#  DllCanUnloadNow
#   DllGetClassObject
#   DllInstall
#   DllRegisterServer
#   DllUnregisterServer
# http://www.microsoft.com/en-us/download/details.aspx?id=43360
# API
# http://msdn.microsoft.com/en-us/library/ie/dn722338%28v=vs.85%29.aspx

# Sample project
# https://code.msdn.microsoft.com/windowsdesktop/Internet-Explorer-02ac106f
# http://msdn.microsoft.com/en-us/library/ie/dn725045%28v=vs.85%29.aspx

#WebDriver will only run against the DeveloperPreview build. Please run this EXE
#with the following argument:
#For x64 Systems:
     /appvve:9BD02EED-6C11-4FF0-8A3E-0B4733EE86A1_6A0357B5-AB99-4856-8A59-CF2C38579E78
#Or for x86 Systems:
     /appvve:9BD02EED-6C11-4FF0-8A3E-0B4733EE86A1_681E2361-2C6F-4D47-A8B7-D3F7B288CB45

# Test code runs successfully, but the nag screen prompts for
# install the latest version of Internet Explorer Developer Channel
# from 
# http://go.microsoft.com/fwlink/?LinkId=396394
# which in turn requires installing Windows 10 Technical Preview
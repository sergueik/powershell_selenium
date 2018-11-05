### Info

This directory contains a replica of win22 tray chromedriver management application
[m3zercat/ChromeDriverKillerTray](https://github.com/m3zercat/ChromeDriverKillerTray)
The intent is to convert the project to Powershell script for ease of distribution similar to e.g.
[Notification icon in the system tray Powershell example](https://github.com/sergueik/powershell_ui_samples/blob/master/notify_icon.ps1).

Note: On windows the chromedriver is often  started invisibly e.g. 
```powershell
start-process -windowstyle hidden ${env:USERPROFILE}\Downloads\chromedriver.exe -passthru
```  

### See Also
       
  * For a number of versions of Chrome and  Chromedrieer, after a failing Selenium test the Chromedriver [leaving numerous forked Chrome instances hanging around leading to high CPU load]((https://bugs.chromium.org/p/chromedriver/issues/detail?id=2311&q=&colspec=ID%20Status%20Pri%20Owner%20Summary))
  * [original system tray notification example](https://sites.google.com/site/assafmiron/MiscScripts/exchangebackupsummery2)


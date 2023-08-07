
using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.DevTools;
using OpenQA.Selenium.DevTools.V109;
//
using DevToolsSessionDomains = OpenQA.Selenium.DevTools.V109.DevToolsSessionDomains;
using EnableCommandSettings = OpenQA.Selenium.DevTools.V109.Page.EnableCommandSettings;
using AddScriptToEvaluateOnNewDocumentCommandSettings = OpenQA.Selenium.DevTools.V109.Page.AddScriptToEvaluateOnNewDocumentCommandSettings;
using SetDeviceMetricsOverrideCommandSettings = OpenQA.Selenium.DevTools.V109.Emulation.SetDeviceMetricsOverrideCommandSettings;
using SetUserAgentOverrideCommandSettings = OpenQA.Selenium.DevTools.V109.Network.SetUserAgentOverrideCommandSettings;

using System.Linq;
using System;
using System.Management;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Text;
using System.Threading;

class Example {
	
	private readonly static string driverLocation = Environment.GetEnvironmentVariable("CHROMEWEBDRIVER");
	
	static void Main(string[] args) {
		System.Environment.SetEnvironmentVariable("webdriver.chrome.driver", System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Replace("file:\\", ""));
		var options = new ChromeOptions();
		// options.AddArgument("--start-maximized");
		IWebDriver driver = new ChromeDriver(options);
		// NOTE: not using the WebDriver Service
		// var service = ChromeDriverService.CreateDefaultService();
		// service.DriverServicePath = driverLocation;
		// IWebDriver driver = new ChromeDriver(service);	

		
		IDevTools devTools = driver as IDevTools;
		IDevToolsSession session = devTools.GetDevToolsSession();
		var domains = session.GetVersionSpecificDomains<DevToolsSessionDomains>();
		domains.Page.Enable(new EnableCommandSettings());
		domains.Page.AddScriptToEvaluateOnNewDocument(new AddScriptToEvaluateOnNewDocumentCommandSettings() {
			Source = "Object.defineProperty(navigator, 'webdriver', { get: () => undefined })"
		});

		var deviceModeSetting = new SetDeviceMetricsOverrideCommandSettings();
		deviceModeSetting.Width = 600;
		deviceModeSetting.Height = 1000;
		deviceModeSetting.Mobile = true;
		deviceModeSetting.DeviceScaleFactor = 50;
      
		domains.Emulation.SetDeviceMetricsOverride(deviceModeSetting);
		// NOTE: Selenium dev recommends async / await
		// await domains.Emulation.SetDeviceMetricsOverride(deviceModeSetting);
		
		Console.Error.WriteLine("Browser User Agent: " + domains.Browser.GetVersion().Result.UserAgent);
		// https://www.selenium.dev/selenium/docs/api/dotnet/OpenQA.Selenium.DevTools.V112.Network.SetUserAgentOverrideCommandSettings.html

		SetUserAgentOverrideCommandSettings  settings = new SetUserAgentOverrideCommandSettings();
		// settings.UserAgent = "\"Not_A Brand\";v=\"42\", \"Google Chrome\";v=\"109\", \"Chromium\";v=\"109\"";
		
		 
		// settings.UserAgent = "Mozilla/5.0 (iPad; CPU OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5355d Safari/8536.25";
		domains.Network.SetUserAgentOverride(settings);
		// NOTE: ignoring the console logs:
		// ERROR: Couldn't read tbsCertificate as SEQUENCE
		// ERROR: Failed parsing Certificate
		// [5188:7540:0806/195815.500:ERROR:device_event_log_impl.cc(215)] [19:58:15.500] USB: usb_device_handle_win.cc:1046 Failed to read descriptor from node connection: A device attached to the system is not functioning. (0x1F)
	
		driver.Navigate().GoToUrl("https://manytools.org/http-html-text/http-request-headers/");

		driver.Manage().Timeouts().PageLoad = TimeSpan.FromSeconds(30);
		Thread.Sleep(10000);
		driver.Quit();
	}
}

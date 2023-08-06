// origin: https://qna.habr.com/q/1266474?e=13639006#clarification_1709400
// see also: https://stackoverflow.com/questions/72771825/selenium-4-c-sharp-chrome-devtools
// (in Russian)

using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.DevTools;
using OpenQA.Selenium.DevTools.V109;
//
using DevToolsSessionDomains = OpenQA.Selenium.DevTools.V109.DevToolsSessionDomains;
using EnableCommandSettings = OpenQA.Selenium.DevTools.V109.Page.EnableCommandSettings;
using AddScriptToEvaluateOnNewDocumentCommandSettings = OpenQA.Selenium.DevTools.V109.Page.AddScriptToEvaluateOnNewDocumentCommandSettings;
using SetDeviceMetricsOverrideCommandSettings = OpenQA.Selenium.DevTools.V109.Emulation.SetDeviceMetricsOverrideCommandSettings;
using System.Linq;
using System;
using System.Management;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Text;

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
		driver.Navigate().GoToUrl("https://store.epicgames.com/en-US/p/tunche");

		driver.Manage().Timeouts().PageLoad = TimeSpan.FromSeconds(30);

		driver.Quit();
	}
}

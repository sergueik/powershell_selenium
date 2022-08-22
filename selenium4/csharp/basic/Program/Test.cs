using System;
using System.Linq.Expressions;
using System.Text;
using System.Linq;
using NUnit.Framework;
using System.Dynamic;
using System.Collections.Generic;
using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
// using OpenQA.Selenium.DevTools;
// using DevToolsSessionDomains = OpenQA.Selenium.DevTools.V100.DevToolsSessionDomains;
using System.Threading;
using Utils;
using Extensions;

/**
 * Copyright 2022 Serguei Kouzmine
 */

// using System.Net.WebSockets;
using WebSocketSharp;
using Newtonsoft.Json;
using System.Security.Cryptography.X509Certificates;
using System.Net.Security;
using System.Net;


namespace Program {
	[TestFixture]
	public class Test {

		private StringBuilder verificationErrors = new StringBuilder();
		// protected IDevToolsSession session;
		protected IWebDriver driver;
		
		[TearDown]
		public void cleanup() {
			try {
				driver.Quit();
			} catch (Exception) {
				// Ignore errors if unable to close the browser
			}
			Assert.AreEqual("", verificationErrors.ToString());
		}


		
		String wsurl = null;
		String devtoolurl = null;
		
		[SetUp]
		public void setup() {
			ChromeOptions options = new ChromeOptions();
			options.SetLoggingPreference(LogType.Driver, OpenQA.Selenium.LogLevel.Debug);

			driver = new ChromeDriver(options);
			ILogs logs = driver.Manage().Logs;
			// NOTE: With Selenium 3.x getting
			// System.NullReferenceException here
			var entries = logs.GetLog(LogType.Driver); 
			// will also see:
			// Launching chrome: "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" --allow-pre-commit-input --disable-background-networking --disable-backgrounding-occluded-windows --disable-client-side-phishing-detection --disable-default-apps --disable-hang-monitor --disable-popup-blocking --disable-prompt-on-repost --disable-sync --enable-automation --enable-blink-features=ShadowDOMV0 --enable-logging --log-level=0 --no-first-run --no-service-autorun --password-store=basic --remote-debugging-port=0 --test-type=webdriver --use-mock-keychain --user-data-dir="C:\Users\Serguei\AppData\Local\Temp\scoped_dir10036_1503715160" data:
			foreach (var entry in entries) {
				var line = entry.ToString();
				if (line.Contains("DevTools HTTP Request: http://localhost")) {
					Console.WriteLine("Inspect log: " + line);
					devtoolurl = line.FindMatch(@"(?<url>http://localhost:\d+/)");
					// TODO: open connection and read
					Console.WriteLine("Connect to dev tools url: " + devtoolurl);
					RestClient restClient = new RestClient(devtoolurl);

					foreach (dynamic response in restClient.Get ("json")) {
						Console.WriteLine("type: " + response.type);
						Console.WriteLine("webSocketDebuggerUrl: " + response.webSocketDebuggerUrl);
						wsurl = response.webSocketDebuggerUrl;
					}
				}
			}
			// IDevTools devTools = driver as IDevTools;
			// DevTools Session
			// session = devTools.GetDevToolsSession();
		}

		[Test]
		public void test()
		{
			try {
				using (var ws = new WebSocket(wsurl)) {
					ws.OnMessage += (sender, e) => Console.WriteLine("result: " + e.Data);
					ws.Connect();
					ws.Send(@"{""id"":534427,""method"":""Browser.getVersion"",""params"":{}}");
					// Console.ReadKey(true);
					Thread.Sleep(1000);
				}
			// TODO: WebSocketSharp.WebSocketException: The header of a frame cannot be read from the stream.
			} catch (Exception ex) {
				Console.WriteLine("ERROR: " + ex.ToString());
			}
  
			driver.Navigate().GoToUrl(devtoolurl + "json/version");
			var pageSource = driver.PageSource;
			Thread.Sleep(1000);
			StringAssert.Contains("Browser", pageSource);
		}
		private static bool RemoteServerCertificateValidationCallback(object sender,
			X509Certificate certificate, X509Chain chain, SslPolicyErrors sslPolicyErrors)
		{
			return true;
		}
	}
		
}

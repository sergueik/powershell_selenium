using System;
using System.Linq.Expressions;
using System.Text;
using System.Linq;
using NUnit.Framework;
using System.Dynamic;
using System.Collections.Generic;
using System.Collections.Generic;
using System.Collections.ObjectModel;
// using OpenQA.Selenium.Environment;
using OpenQA.Selenium;
using OpenQA.Selenium.Remote;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.Interactions;
using OpenQA.Selenium.Support.UI;

using fastJSON;
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
		private WebDriverWait wait;
		private Actions actions;
		private const int wait_seconds = 3;
		private const long wait_poll_milliseconds = 300;
		private String webSocketURL = null;
		private String devtoolurl = null;
		private int id;

		[TearDown]
		public void cleanup() {
			try {
				driver.Quit();
			} catch (Exception) {
				// Ignore errors if unable to close the browser
			}
			Assert.AreEqual("", verificationErrors.ToString());
		}


		[SetUp]
		public void setup() {

			ChromeOptions options = new ChromeOptions();
			options.SetLoggingPreference(LogType.Driver, OpenQA.Selenium.LogLevel.Debug);

			driver = new ChromeDriver(options);
			wait = new WebDriverWait(driver, TimeSpan.FromSeconds(wait_seconds));
			wait.PollingInterval = TimeSpan.FromMilliseconds(wait_poll_milliseconds);
			actions = new Actions(driver);
			// TODO: With Selenium 3.x the GetLog is getting
			// System.NullReferenceException
			ILogs logs = driver.Manage().Logs;
			// Assert.IsTrue(logs !=  null);
			var entries = logs.GetLog(LogType.Driver);

			// will also see:
			// Launching chrome: "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" --allow-pre-commit-input --disable-background-networking --disable-backgrounding-occluded-windows --disable-client-side-phishing-detection --disable-default-apps --disable-hang-monitor --disable-popup-blocking --disable-prompt-on-repost --disable-sync --enable-automation --enable-blink-features=ShadowDOMV0 --enable-logging --log-level=0 --no-first-run --no-service-autorun --password-store=basic --remote-debugging-port=0 --test-type=webdriver --use-mock-keychain --user-data-dir="C:\Users\Serguei\AppData\Local\Temp\scoped_dir10036_1503715160" data:
			foreach (var entry in entries) {
				var line = entry.ToString();
				if (line.Contains("DevTools HTTP Request: http://localhost")) {
					Console.WriteLine("Inspect log: " + line);
					devtoolurl = line.FindMatch(@"(?<url>http://localhost:\d+/)");
					// TODO: open connection and read
					Console.WriteLine("Read configuration from dev tools url: " + devtoolurl);
					var restClient = new RestClient(devtoolurl);

					foreach (dynamic response in restClient.Get ("json")) {
						Console.WriteLine("type: " + response.type);
						Console.WriteLine("webSocketDebuggerUrl: " + response.webSocketDebuggerUrl);
						webSocketURL = response.webSocketDebuggerUrl;
					}
				}
			}
		}

		[Test]
		// [Ignore("Ignore a test")]
		public void test1() {
			try {
				using (var webSocket = new WebSocket(webSocketURL)) {
					webSocket.OnMessage += (sender, e) => {
						var data = e.Data;
						Console.WriteLine("raw data: " + data);
						// does not work
						// Dictionary<string,object> result = Extensions.JSONProcessor.Parse<Dictionary<string,object>>(data);
						// id = result["id"];
						// Console.WriteLine("result id: " + id);

						Dictionary<string,object> response = JSON.ToObject<Dictionary<string,object>>(data);
						int.TryParse(response["id"].ToString(), out id);
						Console.WriteLine("result id: " + id);
						var result = (Dictionary<string,object>)response["result"];
						var userAgent = result["userAgent"];
						Console.WriteLine("result userAgent: " + userAgent);
					};

					webSocket.Connect();
					id = 534427;
					var payload = buildGetVersion(id);
					Console.WriteLine(String.Format("sending: {0}", payload));
					webSocket.Send(payload);
					Thread.Sleep(1000);
				}
			} catch (Exception e) {
				// TODO: WebSocketSharp.WebSocketException: The header of a frame cannot be read from the stream.
				Console.WriteLine("Exception (ignored): " + e.ToString());
			}

			driver.Navigate().GoToUrl(devtoolurl + "json/version");
			var pageSource = driver.PageSource;
			Thread.Sleep(1000);
			StringAssert.Contains("Browser", pageSource);
		}


		[Test]
		public void test2() {

			try {
				using (var webSocket = new WebSocket(webSocketURL)) {
					webSocket.OnMessage += (sender, e) => {
						var data = e.Data;
						Console.WriteLine("raw data: " + data);
						Dictionary<string,object> response = JSON.ToObject<Dictionary<string,object>>(data);
						int.TryParse(response["id"].ToString(), out id);
						Console.WriteLine("result id: " + id);
						Console.WriteLine("result: " + response["result"]);
					};

					webSocket.Connect();
					this.id = 534427;
					var payload = buildClearGeolocationOverrideMessage(id);
					webSocket.Send(payload);
					Thread.Sleep(1000);
				}
			} catch (Exception e) {
				Console.WriteLine("Exception (ignored): " + e.ToString());
			}


			try {
				using (var webSocket = new WebSocket(webSocketURL)) {
					webSocket.OnMessage += (sender, e) => {
						var data = e.Data;
						Console.WriteLine("raw data: " + data);

						Dictionary<string,object> response = JSON.ToObject<Dictionary<string,object>>(data);
						id = (int)response["id"];
						Console.WriteLine("result id: " + id);
						var result = (Dictionary<string,object>)response["result"];
						var userAgent = result["userAgent"];
						Console.WriteLine("result userAgent: " + userAgent);
					};

					webSocket.Connect();
					const double latitude = 37.422290;
					const double longitude = -122.084057;
					const long accuracy = 100;
					id = 534428;
					var payload = buildSetGeolocationOverrideMessage(id, latitude, longitude, accuracy);
					webSocket.Send(payload);
					Thread.Sleep(1000);
				}
			} catch (Exception e) {
				Console.WriteLine("Exception (ignored): " + e.ToString());
			}

			driver.Navigate().GoToUrl("https://www.google.com/maps");
			By locator = By.CssSelector("div[jsaction*='mouseover:mylocation.main']");
			// https://stackoverflow.com/questions/65821815/how-to-use-expectedconditions-in-selenium-4
			// https://stackoverflow.com/questions/42421148/wait-untilexpectedconditions-doesnt-work-any-more-in-selenium
			// https://stackoverflow.com/questions/49866334/c-sharp-selenium-expectedconditions-is-obsolete
			// TODO: address
			// wait.Until(ExpectedConditions.ElementIsVisible(locator));
			Thread.Sleep(10000);
			IList<IWebElement> elements = driver.FindElements(locator);
			Assert.IsTrue(elements.Count > 0);
			elements[0].Click();
			Thread.Sleep(20000);
		}
		
		private String buildGetVersion(int id) {
			const string message = "Browser.getVersion";
			return buildMessage(id, message);
		}

		private String buildSetGeolocationOverrideMessage (int id, double latitude, double longitude, long accuracy) {
			var param = new Dictionary<string,object>();
			const string message = "Emulation.setGeolocationOverride";
			param["latitude"] = latitude;
			param["longitude"] = longitude;
			param["accuracy"] = accuracy;
			return buildMessage(id, message, param);
		}

		private String buildClearGeolocationOverrideMessage(int id) {
			const string message = "Emulation.clearGeolocationOverride";
			return buildMessage(id, message);
		}

		private String buildMessage(int id, String method) {
			return buildMessage(id, method, new Dictionary<string,object>());
		}

		private String buildMessage(int id, String method, Dictionary<string,object> param) {
			var message = new Dictionary<string,object>();
			message["params"] = param;
			message["method"] = method;
			message["id"] = id;
			var payload = JSON.ToJSON(message);
			Console.WriteLine(String.Format("sending: {0}", payload));
			return payload;
		}

		private void processMessage() {
		}

		private static bool RemoteServerCertificateValidationCallback(object sender,
			X509Certificate certificate, X509Chain chain, SslPolicyErrors sslPolicyErrors) {
			return true;
		}
	}

}

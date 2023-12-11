using NUnit.Framework;

using System;
using System.Text;
using System.Linq;
using System.Collections.Generic;
using System.Threading;

using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.DevTools;
using OpenQA.Selenium.DevTools.V109.Network;
using DevToolsSessionDomains = OpenQA.Selenium.DevTools.V109.DevToolsSessionDomains;
using Fetch = OpenQA.Selenium.DevTools.V109.Fetch;
using FetchAdapter = OpenQA.Selenium.DevTools.V109.Fetch.FetchAdapter;
using GetResponseBodyCommandResponse = OpenQA.Selenium.DevTools.V109.Fetch.GetResponseBodyCommandResponse;
using ContinueRequestCommandResponse = OpenQA.Selenium.DevTools.V109.Fetch.ContinueRequestCommandResponse;
using GetResponseBodyCommandSettings = OpenQA.Selenium.DevTools.V109.Fetch.GetResponseBodyCommandSettings;
using RequestPausedEventArgs = OpenQA.Selenium.DevTools.V109.Fetch.RequestPausedEventArgs;
using FulfillRequestCommandResponse = OpenQA.Selenium.DevTools.V109.Fetch.FulfillRequestCommandResponse;

using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

// origin: https://github.com/metaljase/SeleniumCaptureHttpResponse/blob/main/Metalhead.SeleniumCaptureHttpResponse.CDP/Program.cs
namespace Test {
	
	[TestFixture]
	public class FetchTests {
		private static EventWaitHandle waitForHttpResponse;
		private readonly static string driverLocation = Environment.GetEnvironmentVariable("CHROMEWEBDRIVER");
		private StringBuilder verificationErrors = new StringBuilder();
		private IWebDriver driver;
		private IDevTools devTools;
		private bool headless = true;
		private IDevToolsSession session;
		private DevToolsSessionDomains domains;
		private const String baseURL = "https://www.whatismybrowser.com/detect/what-http-headers-is-my-browser-sending";
		private FetchAdapter fetchAdaptor;
		private Response response = null;
		
		[SetUp]
		public void SetUp() {
			System.Environment.SetEnvironmentVariable("webdriver.chrome.driver", System.IO.Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Replace("file:\\", ""));
			var options = new ChromeOptions();
			// options.AddArgument("--start-maximized");
			if (headless) { 
				options.AddArgument("--headless");
			}
			driver = new ChromeDriver(options);
			// NOTE: not using the WebDriver Service with this version of Selenium

			driver.Manage().Timeouts().AsynchronousJavaScript = TimeSpan.FromSeconds(5);
			waitForHttpResponse = new EventWaitHandle(false, EventResetMode.AutoReset);
		
			devTools = driver as IDevTools;
			// TODO: detect Windows 7 and abort the test otherwise
			// System.PlatformNotSupportedException:
			// The WebSocket protocol is not supported on this platform.
			session = devTools.GetDevToolsSession();
			domains = session.GetVersionSpecificDomains<DevToolsSessionDomains>();			
		}

		[Test]
		public void test() {
			fetchAdaptor = domains.Fetch;
			var enableCommandSettings = new Fetch.EnableCommandSettings();
			var requestPattern = new Fetch.RequestPattern {
				// Optional: Wildcards are allowed ('*' = zero or more, '?' = one). Escape character is backslash. Omitting is equivalent to "*".
				UrlPattern = "https://jsonplaceholder.typicode.com/users/",
				// Optional: Stage at which to begin intercepting requests. Default is Request.
				RequestStage = Fetch.RequestStage.Response,
				// Optional: If set, only requests for matching resource types will be intercepted.
				ResourceType = ResourceType.XHR
			};
			enableCommandSettings.Patterns = new Fetch.RequestPattern[] { requestPattern };
			fetchAdaptor.Enable(enableCommandSettings);

			fetchAdaptor.RequestPaused += ResponseInterceptedAsync;

			driver.Url = "https://metaljase.github.io/SeleniumCaptureHttpResponse.html";

			// Wait until thread is unblocked (in ResponseInterceptedAsync), unless timeout is exceeded.
			if (!waitForHttpResponse.WaitOne(TimeSpan.FromSeconds(10))) {
				Console.WriteLine("Timeout while waiting for HTTP response.");
			} else if (response != null && response.RequestPausedEventArgs.ResponseStatusCode == 200) {
				// Output contents of message body returned in HTTP response.
				Console.Error.WriteLine("Response:\n" + response);
				var responseObject = processResponse(response.ToString());
				Console.Error.WriteLine("Response Object:\n" + responseObject);
				// NOTE: Keyword 'void' cannot be used in this context (CS1547)
			}

			fetchAdaptor.RequestPaused -= ResponseInterceptedAsync;
			session.Dispose();
			waitForHttpResponse.Dispose();
		
		}
		
		private async void ResponseInterceptedAsync(object sender, Fetch.RequestPausedEventArgs e) {
			// Wait for response body.
			var getResponseBodyCommandResponse = await fetchAdaptor.GetResponseBody(new GetResponseBodyCommandSettings() {
				RequestId = e.RequestId
			});
			// Store response and message body.
			response = new Response(e, getResponseBodyCommandResponse);
			// Continue loading paused response.  Fetch.FulfillRequest can be used instead of Fetch.ContinueResponse.
			await fetchAdaptor.ContinueResponse(new Fetch.ContinueResponseCommandSettings() {
				RequestId = e.RequestId
			});

			// Captured HTTP response; unblock the thread.
			waitForHttpResponse.Set();
		}

		[TearDown]
		public void TearDown() {
			try {
				driver.Close();
				driver.Quit();
			} catch (Exception) {
			} /* Ignore cleanup errors */
			Assert.AreEqual("", verificationErrors.ToString());
		}


		private static IWebDriver CreateWebDriver(string browserPath, string driverPath) {
			var service = ChromeDriverService.CreateDefaultService(driverPath);
			service.EnableVerboseLogging = false;

			var options = new ChromeOptions { BinaryLocation = browserPath };
			options.AddArgument("incognito");

			return new ChromeDriver(service, options);
		}

		private dynamic processResponse(string resp = null) {
			
			if (resp.StartsWith ("["))
			    return JArray.Parse (resp);
			else
			    return JsonConvert.DeserializeObject<Dictionary<String,Object>>(resp);	
				// return JsonConvert.DeserializeObject<DynamicDictionary>(resp);	
				
		}
		

	}
}

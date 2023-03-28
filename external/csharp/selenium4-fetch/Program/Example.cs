// origin: https://qna.habr.com/q/1266474?e=13639006#clarification_1709400
// (in Russian)

using OpenQA.Selenium;
using OpenQA.Selenium.Chrome;
using OpenQA.Selenium.DevTools;
using OpenQA.Selenium.DevTools.V109;
using System.Linq;
using System;
using System.Management;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Text;

class Example {
    static void Main(string[] args) {
        var options = new ChromeOptions();
        options.AddArgument("--start-maximized");
        IWebDriver driver = new ChromeDriver(options);

        var xhrUrls = new List<string>();
        var handler = new NetworkRequestHandler();
        handler.RequestTransformer = (request) => { return request; };
        handler.RequestMatcher = httprequest => {
        	// works fine under debugger. but fails without debugger with exceptions like:
        	// System.InvalidOperationException: A command response was not received: Fetch.continueRequest
			// System.InvalidOperationException: There is already one outstanding 'SendAsync' call for this WebSocket instance. ReceiveAsync and SendAsync can be called simultaneously, but at most one outstanding operation for each of them is allowed at the same time.
			// see also: https://github.com/SeleniumHQ/selenium/issues/10564
            xhrUrls.Add(httprequest.Url);
            // the name 'Fetch' does not exist in the current context
            // Fetch.continueRequest(httprequest);
            return false;
        };

        INetwork networkInterceptor = driver.Manage().Network;
        networkInterceptor.AddRequestHandler(handler);

        networkInterceptor.StartMonitoring();

        driver.Navigate().GoToUrl("https://store.epicgames.com/en-US/p/tunche");

        driver.Manage().Timeouts().PageLoad = TimeSpan.FromSeconds(30);

        networkInterceptor.StopMonitoring();

        foreach (var url in xhrUrls)
        {
            Console.WriteLine(url);
        }

        driver.Quit();
    }
}

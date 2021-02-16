https://www.codeproject.com/Articles/787565/Lightweight-Wait-Until-Mechanism

https://automationrhapsody.com/efficient-waiting-for-ajax-call-data-loading-with-selenium-webdriver/

private static void WaitForReady()
{
	WebDriverWait wait = new WebDriverWait(webDriver, waitForElement);
	wait.Until(driver => (bool)((IJavaScriptExecutor)driver).
			ExecuteScript("return jQuery.active == 0"));



}


private static void WaitForReady()
{
	WebDriverWait wait = new WebDriverWait(webDriver, waitForElement);
	wait.Until(driver =>
	{
		bool isAjaxFinished = (bool)((IJavaScriptExecutor)driver).
			ExecuteScript("return jQuery.active == 0");
		try
		{
			driver.FindElement(By.ClassName("spinner"));
			return false;
		}
		catch
		{
			return isAjaxFinished;
		}
	});
}

// origin: https://sqa.stackexchange.com/questions/27711/selenium-c-how-to-wait-with-webdriverwait-using-the-element-as-parameter-inst
public static Func<IWebDriver, bool> ElementIsVisible(IWebElement element)
{
    return (driver) =>
    {
        try
        {
            return element.Displayed;
        }
        catch (Exception)
        {
            // If element is null, stale or if it cannot be located
            return false;
        }
    };
}

// TextToBePresentInElementValue(IWebElement, String)
// https://www.selenium.dev/selenium/docs/api/dotnet/html/M_OpenQA_Selenium_Support_UI_ExpectedConditions_TextToBePresentInElement.htm
// https://www.selenium.dev/selenium/docs/api/dotnet/html/M_OpenQA_Selenium_Support_UI_ExpectedConditions_TextToBePresentInElementValue.htm

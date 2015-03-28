# http://stackoverflow.com/questions/17555280/selenium-webdriver-jquery
<#
#
# TODO : Convert from Java to C# / Powershell 
# iWebdriver jQuery Extension, This will work across all browsers. Copy and paste to your webdriver extension.

  public static IWebElement FindByTextJQuery(this IWebDriver driver, string Tagname, string Text)
    {
        IJavaScriptExecutor js = (IJavaScriptExecutor)driver;
        bool flag = (bool)js.ExecuteScript("return typeof jQuery == 'undefined'");
        if (flag)
        {
            js.ExecuteScript("var jq = document.createElement('script');jq.src = '//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js';document.getElementsByTagName('head')[0].appendChild(jq);");
        }
        driver.WaitForAjax();
        js.ExecuteScript("$('" + Tagname + ":contains(" + Text + ")').css('background-color', '')");
        IWebElement elements = (IWebElement)js.ExecuteScript(@"return $('"+Tagname+":contains("+Text+")')[0]");
        return elements;
    }

 public static string getTextByJquery(this IWebDriver driver, string jquery)
    {
        IJavaScriptExecutor js = (IJavaScriptExecutor)driver;
        string elementsText = (string)js.ExecuteScript("return $('" + jquery +    "').text()");
        return elementsText;
    }

 public static int returnIndexByJquery(this IWebDriver driver, string jQuery)
    {

        IJavaScriptExecutor js = (IJavaScriptExecutor)driver;
        bool flag = (bool)js.ExecuteScript("return typeof jQuery == 'undefined'");
        if (flag)
        {
            js.ExecuteScript("var jq = document.createElement('script');jq.src = '//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js';document.getElementsByTagName('head')[0].appendChild(jq);");
        }
        driver.WaitForAjax();
      //  js.ExecuteScript(@"return $('" + Tagname + ":contains(" + Text + ")').css('background-color', 'blue')");
        Int64 elementIndex = (Int64)js.ExecuteScript(@"return $('"+jQuery+"').index()[0]");
        return Convert.ToInt32(elementIndex);                     
    }

   public static int returnCountByJquery(this IWebDriver driver, string jQuery)
    {
        IJavaScriptExecutor js = (IJavaScriptExecutor)driver;
        bool flag = (bool)js.ExecuteScript("return typeof jQuery == 'undefined'");
        if (flag)
        {
            js.ExecuteScript("var jq = document.createElement('script');jq.src = '//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js';document.getElementsByTagName('head')[0].appendChild(jq);");
        }
        driver.WaitForAjax();
        //  js.ExecuteScript(@"return $('" + Tagname + ":contains(" + Text + ")').css('background-color', 'blue')");
        Int64 elementCount = (Int64)js.ExecuteScript(@"return $('" + jQuery + "').size()");
        return Convert.ToInt32(elementCount);
    }

# see also http://www.vcskicks.com/selenium-jquery.php
# https://cssgreut.wordpress.com/2010/12/20/run-selenium-ide-tests-with-jquery-selectors/
#>


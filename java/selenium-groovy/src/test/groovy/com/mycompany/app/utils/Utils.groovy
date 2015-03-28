package com.mycompany.app.utils;

import com.mycompany.app.SeleniumConstants;



import org.apache.log4j.LogManager;
import org.apache.log4j.Logger
import org.openqa.selenium.JavascriptExecutor;
import org.openqa.selenium.By;
import org.openqa.selenium.TimeoutException;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.interactions.Actions
import org.openqa.selenium.support.ui.ExpectedCondition;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import com.mycompany.app.PropertyHolder;
import com.mycompany.app.SeleniumConstants;

class Utils {

	private static Logger logger = LogManager.getLogger(Utils.class);
	private WebDriver driver;
	private String startUrl;
	private String userName;
	private String passWord;

	public Utils(WebDriver driver,String startUrl) {
		this.driver = driver;
		this.startUrl = startUrl;
	}

	public void setUserName(String name) {
		this.userName = name;
	}

	public void setPassWord(String password) {
		this.passWord = password;
	}

	public WebElement waitForElementPresent(By by, long timeoutInSeconds) throws Exception {
		boolean wasFailure = false;
		WebElement el = null;
		try {
			WebDriverWait wait = new WebDriverWait(driver, timeoutInSeconds);
			el = wait.until(ExpectedConditions.presenceOfElementLocated(by));
			return el;
		} catch(TimeoutException e) {
			wasFailure = true;
			throw new TimeoutException("!Element  \"" + by.toString() + "\" could not be found within " + timeoutInSeconds + " seconds.");
		}
		catch(Exception e) {
			wasFailure = true;
			throw e;
		}
	}

	public WebElement waitForElementVisible(By by, long timeoutInSeconds) throws Exception {
		boolean wasFailure = false;
		WebElement el = null;
		try {
			WebDriverWait wait = new WebDriverWait(driver, timeoutInSeconds);
			el = wait.until(ExpectedConditions.visibilityOfElementLocated(by));
			return el;
		} catch(TimeoutException e) {
			wasFailure = true;
			throw new TimeoutException("!Element  \"" + by.toString() + "\" could not be found within " + timeoutInSeconds + " seconds.");
		}
		catch(Exception e) {
			wasFailure = true;
			throw e;
		}
	}

	//will check every second and return true when it can locate the requested element
	public boolean isElementPresent(By by, long timeoutInSeconds) throws Exception {
		boolean returnValue = false;
		int size = 0;
		int ticker = 0;
		while (size == 0 && ticker < timeoutInSeconds) {
			size = driver.findElements(by).size();
			sleep(1000);
			ticker++;
		}

		if (size > 0) {
			returnValue = true;
		}
		return returnValue;
	}


	def visualizeClick(int x,int y) {
		String script = """
	visualize_click = function(x,y){


	\$('#selenium-dot').remove();
	\$('<div>')
		.attr({id: 'selenium-dot'})
		.css({
			'position': 	'absolute',
			'z-index': 		10000,
			'top': 			y,
			'left': 		x,
			'background': 	'red',
			'width': 		6,
			'height': 		6,
			'margin': 		'-3px 0 0 -3px',
			'border-radius':'3px'
		})
		.appendTo('body');

};

"""
		println("loaded function visualize_click");
		executeJS(script);
		println "loaded selenium-dot function";
		executeJS("visualize_click($x,$y)");
	}

	public void executeJS(String statement) {
		JavascriptExecutor js = (JavascriptExecutor) driver;
		js.executeScript(statement);
	}

	public Object evalJS(String statement) {
		JavascriptExecutor js = (JavascriptExecutor) driver;
		return js.executeScript("return " + statement);
	}



	private ExpectedCondition<WebElement> visibilityOfElementLocated(final By locator) {
		def c = {driver ->
			WebElement toReturn = driver.findElement(locator);
			if (toReturn.isDisplayed()) {
				return toReturn;
			}
			return null;
		} as ExpectedCondition<WebElement>;
		return c;
	}
}

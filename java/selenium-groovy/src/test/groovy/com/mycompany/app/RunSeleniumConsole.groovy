package com.mycompany.app

import org.apache.log4j.LogManager;
import org.apache.log4j.Logger
import org.openqa.selenium.WebElement;
import org.openqa.selenium.interactions.Actions;
import org.openqa.selenium.By as By;
import com.mycompany.app.SeleniumConstants as SeleniumConstants;

import com.mycompany.app.utils.ConsoleWaiter;
import com.mycompany.app.utils.Utils;

class RunSeleniumConsole {

	private static Logger logger = LogManager.getLogger(RunSeleniumConsole.class);


	static main(args) {
		logger.info("Starting selenium session with console");
		WebDriverSetup setup = WebDriverSetup.getInstance();

		//set bindings
		Utils utils = new Utils(setup.driver,setup.startUrl);
		utils.setUserName(setup.username);
		utils.setPassWord(setup.password);
		Actions actions = new Actions(setup.driver);

		ConsoleWaiter waiter = new ConsoleWaiter(setup);

		logger.info("Setting bindings for driver,actions,utils,logger");
		waiter.setVar("driver", setup.driver);
		waiter.setVar("actions",actions);
		waiter.setVar("utils",utils);
		waiter.setVar("logger",logger);
		waiter.setVar("startUrl",setup.startUrl);
		waiter.setVar("By",By);
		waiter.setVar("SeleniumConstants",SeleniumConstants);
		waiter.run();
		
		setup.close();
	}
}

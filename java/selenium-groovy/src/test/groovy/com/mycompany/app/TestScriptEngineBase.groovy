package com.mycompany.app

import junitparams.JUnitParamsRunner;
import junitparams.Parameters;
import org.apache.log4j.LogManager
import org.apache.log4j.Logger
import org.junit.After
import org.junit.AfterClass
import org.junit.BeforeClass
import org.junit.Test
import org.junit.runner.RunWith
import org.openqa.selenium.By;
import org.openqa.selenium.interactions.Actions;

import com.mycompany.app.utils.Utils

@RunWith(JUnitParamsRunner.class)
abstract class TestScriptEngineBase {

	private static Logger logger = LogManager.getLogger(TestScriptEngineBase.class);
	protected static WebDriverSetup setup;
	

	public Object[] getFileNames() {
		Vector<String> fileList = new Vector<String>();
		String dirName = getDirName();
		logger.info("Running tests for directory $dirName");
		def dir = new File(dirName);
		dir.eachFile {
			if (it.isFile()) {
				fileList << it.path;
			}
		}
		
		String[] st =new String[fileList.size()];
		fileList.toArray( st );
		return st;
	}
	
	protected abstract String getDirName();
	
	@BeforeClass
	public static void startUpSelenium() {
		setup = WebDriverSetup.getInstance();		
	}
	
	@AfterClass
	public static void closeDriver() {
		setup.close();
	}
	
	
	@Test
	@Parameters(method = "getFileNames")
	public void runTestScript(String testScriptName) {
		logger.info "Testing script $testScriptName.";
		try {
			//start engine with bindings
			String dirName = this.getDirName();
			String[] roots = { dirName.toString() };
			GroovyScriptEngine gse = new GroovyScriptEngine(roots);
			Binding binding = new Binding();
			
			//set bindings
			Utils utils = new Utils(setup.driver,setup.startUrl);
			utils.setUserName(setup.username);
			utils.setPassWord(setup.password);
			Actions actions = new Actions(setup.driver);
	
			logger.info("Setting bindings for driver,actions,utils,logger");
			binding.setVariable("driver", setup.driver);
			binding.setVariable("actions",actions);
			binding.setVariable("utils",utils);
			binding.setVariable("logger",logger);
			binding.setVariable("startUrl",setup.startUrl);
			binding.setVariable("By",By);
			binding.setVariable("SeleniumConstants",SeleniumConstants);
			gse.run(testScriptName, binding);
		}
		catch (AssertionError assertionError) {
			println assertionError;
			throw assertionError;
		}
	}
	
}

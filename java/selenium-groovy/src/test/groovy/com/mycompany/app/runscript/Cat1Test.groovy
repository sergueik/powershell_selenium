package com.mycompany.app.runscript

import com.mycompany.app.TestScriptEngineBase;

import java.util.Collection;

import org.junit.runners.Parameterized.Parameters;


import org.apache.log4j.LogManager;
import org.apache.log4j.Logger
import org.junit.BeforeClass;
import org.junit.Test;

import com.mycompany.app.TestScriptEngineBase;

class Cat1Test extends TestScriptEngineBase {

	private static Logger logger = LogManager.getLogger(Cat1Test.class);

	public String getDirName() {
		return "src/test/resources/scripts/cat1";
	}
//	@Parameters
//	public static Collection<Object[]> data() {
//		TestScriptEngineBase.metaClass.static.getDirName = { -> "src/test/resources/scripts/roadoptions" };
//		return TestScriptEngineBase.data();
//	}	
	
}

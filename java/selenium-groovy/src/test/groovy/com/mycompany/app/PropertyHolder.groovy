package com.jankester.selenium.test

class PropertyHolder {

	public static Properties testProperties = new Properties(); 
	
	static {
		InputStream is = PropertyHolder.class.classLoader.getResourceAsStream('test.properties');
		testProperties.load(is);
        //def theConfig = new ConfigSlurper().parse(is.getText());
	}
}

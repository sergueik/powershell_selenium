# http://www.codeproject.com/Articles/856324/Perform-right-click-action-using-WebDriver
<#

import java.util.concurrent.TimeUnit;

import org.openqa.selenium.By;
import org.openqa.selenium.Keys;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.interactions.Actions;

public class Right_click {

public static void main(String args[]) throws Exception{

       // Initialize WebDriver
       WebDriver driver = new FirefoxDriver();
       // Wait For Page To Load
       driver.manage().timeouts().implicitlyWait(120,TimeUnit.SECONDS);
   
       // Go to Myntra Page 
        driver.get("http://www.myntra.com/");
      
       // Maximize Window
       driver.manage().window().maximize();
      
      WebElement R1 = driver.findElement(By.xpath("//a[@href='/shop/men?src=tn&nav_id=5']"));
      
      // Initialize Actions class object
      Actions builder = new Actions(driver);
      
      // Perform Right Click on  MEN and  Open "Men" content in a new tab 
      builder.contextClick(R1).sendKeys(Keys.ARROW_DOWN).sendKeys(Keys.ENTER).perform();
      //ContextClick() is a method to use right click 
    
      /* Perform Right Click on  MEN and  Open "Men" content in a new different Window
      
       builder.contextClick(hindiLanguage).sendKeys(Keys.ARROW_DOWN).sendKeys(Keys.ARROW_DOWN).sendKeys(Keys.ENTER).perform();
  
      //closing current driver window 
      driver.close();
     */	
		
	}

}

#>

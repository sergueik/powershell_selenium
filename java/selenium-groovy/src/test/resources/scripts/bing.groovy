driver.get('http://www.bing.com/maps/');

//make more space on map
elem = driver.findElement(By.id('slider'));
actions.moveToElement(elem).click().perform();

//search for a city
elem = driver.findElement(By.id('sb_form_q'));
elem.sendKeys('Netherlands, Bennekom');
elem = driver.findElement(By.id('sb_form_go'));
actions.moveToElement(elem).click().perform();

//close left side
elem = driver.findElement(By.id('closeTaskAreaButton'));
actions.moveToElement(elem).click().perform();

//find map container
elem = driver.findElement(By.id('msve_mapContainer'));
actions.moveToElement(elem,200,200).contextClick().perform();

//set up a routing request
elem = utils.waitForElementVisible(By.id('aid_Directions_to_here'),2);
//actions.moveToElement(elem,10,0).moveByOffset(-10,0).click().perform();
actions.moveToElement(elem).click().perform();

//setup A
elem = utils.waitForElementVisible(By.id('TaskHost_DrivingDirectionsWaypointInput1'),2);
elem.sendKeys('Netherlands, Arnhem');

//click go
elem = driver.findElement(By.id('TaskHost_DrivingDirectionsShowDirections'));
actions.moveToElement(elem).click().perform();

//assert time
elem = utils.waitForElementVisible(By.id('dd_time'),2);
println elem.text;
assert elem.text =~ '26 min','We expect a routing result of 26 min.';



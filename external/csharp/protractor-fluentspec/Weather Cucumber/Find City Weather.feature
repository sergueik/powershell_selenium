Feature: SpecFlowFeature1
	In order to verify that I am able to search for cities
	As an end user
	I want to be have my entered city's weather returned

	
#In future might want to add edge case for auto-completion of cities with same name
@Short
Scenario: Find City Weather
	Given I am on the URL www.weather.com
	And I have entered Jacksonville, FL into the search bar
	When I search by clicking the magnifying glass
	Then I should be taken to the weather page for Jacksonville
	And the temperature should be between 0 and 110


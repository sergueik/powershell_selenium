#!/usr/bin/env python3

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.support import expected_conditions

# https://stackoverflow.com/questions/47420957/create-custom-wait-until-condition-in-python
# https://selenium-python.readthedocs.io/waits.html
class waittest:
  def __init__(self, locator, attr, value):
    self._locator = locator
    self._attribute = attr
    self._attribute_value = value

  def __call__(self, driver):
    element = driver.find_element_by_xpath(self._locator)
    if element.get_attribute(self._attribute) == self._attribute_value:
      return element
    else:
      return None

class waittest2:
  def __init__(self, locator1, locator2, attr, value):
    self._locator1 = locator1
    self._locator2 = locator2
    self._attribute = attr
    self._attribute_value = value

  def __call__(self, driver):
    element1 = driver.find_element_by_xpath(self._locator1)
    element2 = element1.find_element_by_xpath(self._locator2)
    if element2.get_attribute(self._attribute) == self._attribute_value:
      return element2
    else:
      return None

driver = webdriver.Firefox()
driver.get('http://www.ubuntu.com/')
# element = WebDriverWait(driver, 10).until(
#   waittest('//*[@id="navigation"]/div/div/div', 'class', 'p-navigation__logo')
# )
# print element.get_attribute('innerHTML')
try:
  element = WebDriverWait(driver, 10).until(
    waittest2('//*[@id="navigation"]/div/div/div','a[@href="/"]', 'class', 'p-navigation__link')
  )
  if element != None:
    print element.get_attribute('innerHTML')
except TimeoutException:
   pass

driver.close()
driver.quit()

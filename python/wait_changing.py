#!/usr/bin/env python3

from os import getenv
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.support import expected_conditions

class waittest2:
  def __init__(self, locator, attribute, initial_value = None):
    self._locator = locator
    self._attribute = attribute
    element = driver.find_element_by_css_selector(self._locator)
    if initial_value == None:
      self.last_value = element.get_attribute(self._attribute)
    else:
      self.last_value = initial_value
    print('Last value:{}'.format(self.last_value))
  def __call__(self, driver):
    element = driver.find_element_by_css_selector(self._locator)
    self.new_value = element.get_attribute(self._attribute)
    if self.last_value != self.new_value:
      print('New value:{}'.format(self.new_value))
      return True
    else:
      print('waiting for change')
      return False

if __name__ == '__main__':
  driver = webdriver.Firefox()
  driver.maximize_window()
  if getenv('OS') != None :
    homedir = getenv('USERPROFILE').replace('\\', '/')
  else:
    homedir = getenv('HOME')
  
  location = 'file:///{0}/{1}'.format('{0}/Downloads'.format(homedir), 'clock.html')
  driver.get(location)

  try:
    status = WebDriverWait(driver, 10).until(
      waittest2('input[name="clock"]', 'value')
    )
    if status:
      print( 'Observed change of value')
  except TimeoutException:
    pass
  finally:
    driver.close()
    driver.quit()

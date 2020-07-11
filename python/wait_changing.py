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
    # origin: https://stackoverflow.com/questions/17082425/running-selenium-webdriver-with-a-proxy-in-python
    self.driver.implicitly_wait(30)
    self.base_url = "https://www.google.ie/"
    self.verificationErrors = []
    self.accept_next_alert = True

  def tearDown(self):
    self.driver.quit()
    self.assertEqual([], self.verificationErrors)

  def is_element_present(self, how, what):
    try:
      self.driver.find_element(by=how, value=what)
    except NoSuchElementException as e:
      return False
    return True

  def is_alert_present(self):
    try:
      self.driver.switch_to_alert()
    except NoAlertPresentException as e:
      return False
    return True

  def close_alert_and_get_its_text(self):
    try:
      alert = self.driver.switch_to_alert()
      alert_text = alert.text
      if self.accept_next_alert:
        alert.accept()
      else:
        alert.dismiss()
      return alert_text
    finally:
      self.accept_next_alert = True

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

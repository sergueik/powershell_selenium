#!/usr/bin/env python

# origin: https://www.techbeamers.com/selenium-webdriver-waits-python/
# see also: https://selenium-python.readthedocs.io/waits.html
import sys
from os import getenv
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import NoAlertPresentException
from selenium.common.exceptions import TimeoutException

if __name__ == '__main__':
  driver = webdriver.Firefox()
  driver.maximize_window()
  if getenv('OS') != None :
    homedir = getenv('HOMEDIR').replace('\\', '/')
  else:
    homedir = getenv('HOME')
  location = 'file:///{0}/{1}'.format('{0}/Downloads'.format(homedir), 'alert.html')
  driver.get(location)

  button = driver.find_element_by_name('alert')
  button.click()

  try:
    WebDriverWait(driver,10).until(EC.alert_is_present())
    alert = driver.switch_to.alert
    msg = alert.text
    print ('Alert message: {}'.format(msg) )
    alert.accept()

  except (NoAlertPresentException, TimeoutException) as e:
    print('Alert was not shown: {0}'.format(e))
    print (e.args)
  finally:
    driver.quit()

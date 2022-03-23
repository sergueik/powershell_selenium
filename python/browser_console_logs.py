#!/usr/bin/env python3

from __future__ import print_function
import time
import sys
import os
import re
from os import getenv
from selenium import webdriver
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
from selenium.webdriver.chrome.options import Options

# print console logs messages
def get_console_errors(driver):
  browserlogs = driver.get_log('driver')
  errors = []
  for entry in browserlogs:
    if entry['level'] == 'SEVERE':
      errors.append(entry)
  return errors

is_windows = getenv('OS') != None and re.compile('.*NT').match( getenv('OS'))
homedir = getenv('USERPROFILE' if is_windows else 'HOME')
print('user home directory path: {}'.format(homedir))
chromedriver_path = homedir + os.sep + 'Downloads' + os.sep + ('chromedriver.exe' if is_windows else 'chromedriver')
options = Options()
print('chromedriver path: {}'.format(chromedriver_path))
# enable browser logging
desired_capabilities = DesiredCapabilities.CHROME
desired_capabilities['goog:loggingPrefs'] = desired_capabilities['loggingPrefs'] = {
  'browser':'ALL'
}
# https://stackoverflow.com/questions/20907180/getting-console-log-output-from-chrome-with-selenium-python-api-bindings

driver = webdriver.Chrome(executable_path = chromedriver_path, desired_capabilities = desired_capabilities)
# load the desired webpage
driver.get('http://www.cnn.com')
time.sleep(10)
console_browserlog_errors = get_console_errors(driver)
for log_entry in console_browserlog_errors:
  print( log_entry)

driver.quit()

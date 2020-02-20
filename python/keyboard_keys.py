#!/usr/bin/env python
# -*- coding: utf-8 -*-
# see also:
# https://www.programcreek.com/python/example/97722/selenium.webdriver.common.keys.Keys.END

import sys
import os
import re
import time
from os import getenv
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException

if __name__ == '__main__':
  os.environ['PYTHONIOENCODING'] = 'utf-8'
  # sys.setdefaultencoding('utf-8')
  driver = webdriver.Firefox()
  driver.maximize_window()
  if getenv('OS') != None :
    homedir = getenv('USERPROFILE').replace('\\', '/')
    # HOMEDIR only defined in some recent versions of Windows
  else:
    homedir = getenv('HOME')
  driver.get('http://www.python.org')
  css_selector = '*[name="q"]'
  try:
    WebDriverWait(driver,10).until(EC.visibility_of_element_located((By.CSS_SELECTOR, css_selector)))
    element = driver.find_element_by_css_selector(css_selector)
    text = 'Lorem ipsum dolor sit amet'
    element.send_keys(text)
    element.send_keys(Keys.HOME )
    time.sleep(10)
    element.send_keys(Keys.END )
    element.send_keys(Keys.BACK_SPACE * len(text) )
    print('Text: "{}"'.format(element.text))
  except ( TimeoutException) as e:
    print('Element is not located: '.format(e))
    print (e.args)
  finally:
    driver.quit()


# export PATH=$PATH:$HOME/Downloads

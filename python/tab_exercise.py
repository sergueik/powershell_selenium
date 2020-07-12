#!/usr/bin/env python3

from __future__ import print_function
import getopt
import sys
import re
import time, datetime, os
from os import getenv
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.common.exceptions import WebDriverException
from selenium.common.exceptions import InvalidArgumentException
from selenium.common.exceptions import NoSuchWindowException
import json, base64

from selenium.webdriver.common.keys import Keys

# https://fooobar.com/questions/13553830/selenium-python-switch-to-new-window
if getenv('OS') != None :
  homedir = getenv('USERPROFILE').replace('\\', '/')
else:
  homedir = getenv('HOME')
options = Options()
# options.add_argument('--headless')
# options.add_argument('--disable-gpu')
chromedriver = homedir + '/' + 'Downloads' + '/' + 'chromedriver'
driver = webdriver.Chrome(chromedriver, options = options)
url = 'http://www.wikipedia.org/'
driver.get(url)
handles = driver.window_handles
num_tabs = len(handles)
orig_handle = handles[0]
element = driver.find_element_by_css_selector('body')
print ('"body" element id: {}'.format(element.get_attribute('id')))

# the following code has no effect on Linux
print('open new tab via keyboard: {}'.format("Keys.CONTROL + 'T'"))
element.send_keys(Keys.CONTROL + 'T')
time.sleep(1)
# reload handles
handles = driver.window_handles
if len(handles) > num_tabs:
  print('window handles: {}'.format(handles))
else:
  print('no extra tabs')
num_tabs = len(handles)

# the following code has no effect on Linux
print('open new tab via keyboard: {}'.format("Keys.CONTROL + Keys.TAB"))
element.send_keys(Keys.CONTROL + Keys.TAB)
time.sleep(1)
# reload handles
handles = driver.window_handles
if len(handles) > num_tabs:
  print('window handles: {}'.format(handles))
else:
  print('no extra tabs')
num_tabs = len(handles)

print('open new tab through script injection')
driver.execute_script("window.open('{}');".format(url))
time.sleep(1)
# reload handles
handles = driver.window_handles
if len(handles) > num_tabs:
  print('window handles: {}'.format(handles))
else:
  print('no extra tabs')
num_tabs = len(handles)
# https://python-3-patterns-idioms-test.readthedocs.io/en/latest/Comprehensions.html
new_handle = [x for x in handles if x != orig_handle][0]
try:
  print('switching to new window handle: {}'.format(new_handle))
  driver.switch_to_window(new_handle)
  print('closing extra window handle: {}'.format(new_handle))
  driver.close()
  print('switching to original window handle: {}'.format(orig_handle))
  driver.switch_to_window(orig_handle)
except WebDriverException as e:
  print('Excepion (ignored): {}'.format(e))
  pass
except InvalidArgumentException as e:
  print('Excepion (ignored): {}'.format(e))
  pass
time.sleep(3)
if driver != None:
  try:
    driver.close()
  except NoSuchWindowException as e:
    print('Excepion (ignored): {}'.format(e))
    pass
  driver.quit()

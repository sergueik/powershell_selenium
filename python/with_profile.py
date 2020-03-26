#!/usr/bin/env python3

from __future__ import print_function
import os
import sys
import re
import time
from os import getenv
from selenium import webdriver
from selenium.common.exceptions import WebDriverException
from selenium.webdriver.chrome.options import Options

is_windows = getenv('OS') != None and re.compile('.*NT').match( getenv('OS'))
homedir = getenv('USERPROFILE' if is_windows else 'HOME')
print('user home directory path: {}'.format(homedir))

chromedriver_path = homedir + os.sep + 'Downloads' + os.sep + ('chromedriver.exe' if is_windows else 'chromedriver')
options = Options()
print('chromedriver path: {}'.format(chromedriver_path))
dir_name = None
if len(sys.argv) > 1:
  dir_name = sys.argv[1]
if dir_name == None:
  dir_name = 'CustomProfile'
user_data_dir ='{0}\\AppData\\Local\\Google\\Chrome\\User Data\\{1}'.format(getenv('USERPROFILE'), dir_name) if is_windows else '/home/{0}/.config/{1}'.format(getenv('USER'), dir_name)
print('user data dir path: {}'.format(user_data_dir))
options.add_argument( 'user-data-dir={}'.format(user_data_dir))
try:
  driver = webdriver.Chrome(executable_path = chromedriver_path, options = options)
except WebDriverException,e :
  driver = None
  print( e)
  pass
  # unknown error: Could not remove old devtools port file. Perhaps the given user-data-dir at ... is still attached to a running Chrome or Chromium process
if driver != None:
  driver.get('chrome://version/')
  time.sleep(10)
  driver.close()
  driver.quit()

# on vanilla Windows node
# PATH=%PATH%;c:\Python27;%USERPROFILE%\Downloads


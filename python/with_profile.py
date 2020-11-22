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

print('user home directory path: {}'.format(homedir), file = sys.stderr)

chromedriver_path = homedir + os.sep + 'Downloads' + os.sep + ('chromedriver.exe' if is_windows else 'chromedriver')

print('chromedriver path: {}'.format(chromedriver_path), file = sys.stderr)

options = Options()
profile_dir_name = None
if len(sys.argv) > 1:
  profile_dir_name = sys.argv[1]
if profile_dir_name == None:
  profile_dir_name = 'CustomProfile'
user_data_dir ='{0}\\AppData\\Local\\Google\\Chrome\\User Data\\{1}'.format(getenv('USERPROFILE'), profile_dir_name) if is_windows else '/home/{0}/.config/{1}'.format(getenv('USER'), profile_dir_name)
if os.path.isdir(user_data_dir):
  print('Custom profile will be used: "{}"'.format(user_data_dir), file = sys.stderr)
else:
  print('Custom profile will be created: "{}"'.format(user_data_dir), file = sys.stderr)

options.add_argument( 'user-data-dir={}'.format(user_data_dir))
try:
  driver = webdriver.Chrome(executable_path = chromedriver_path, options = options)
# TODO: Message: unknown error: Chrome failed to start: exited normally.
# unknown error: DevToolsActivePort file doesn't exist
# The process started from chrome location
# C:\Program Files\Google\Chrome\Application\chrome.exe
# is no longer running, so ChromeDriver is assuming that Chrome has crashed.
# from chromedriver / chrome version mismatch
except WebDriverException,e :
  driver = None
  print(e, file = sys.stderr)
  pass
  # TODO: handle unknown error: Could not remove old devtools port file.
  # Perhaps the given user-data-dir at ... is still
  # attached to a running Chrome or Chromium process
if driver != None:
  driver.get('chrome://version/')

  time.sleep(10)
  driver.close()
  driver.quit()
  if not os.path.isdir(user_data_dir + ('\\' if is_windows else '/') + 'Default' ):
    print('The profile was not created: "{}"'.format(user_data_dir), file = sys.stderr)

# on vanilla Windows node
# PATH=%PATH%;c:\Python27;%USERPROFILE%\Downloads


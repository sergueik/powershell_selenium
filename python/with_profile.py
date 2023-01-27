#!/usr/bin/env python3

from __future__ import print_function
import os,sys,time,re

from selenium import webdriver
from selenium.common.exceptions import WebDriverException
from selenium.webdriver.chrome.options import Options
import getopt

try:
  opts, args = getopt.getopt(sys.argv[1:], 'hdan:', ['help', 'debug', 'headless', 'name='])
except getopt.GetoptError as err:
  print('usage: with_profile.py [-n|--name <name>] [-a|--headless] [-d|--debug] [-h]')
profile_dir_name = None
headless = False
global debug
debug = False
for option, argument in opts:
  if option == '-d':
    debug = True
  elif option in ('-h', '--help'):
    print('usage: with_profile.py [-n|--name <name>] [-a|--headless] [-d|--debug] [-h]')
    exit()
  elif option in ('-a', '--headless'):
   headless = True
  elif option in ('-n', '--name'):
    profile_dir_name = argument

is_windows = os.getenv('OS') != None and re.compile('.*NT').match( os.getenv('OS'))
homedir = os.getenv('USERPROFILE' if is_windows else 'HOME')

print('user home directory path: {}'.format(homedir), file = sys.stderr)

chromedriver_path = homedir + os.sep + 'Downloads' + os.sep + ('chromedriver.exe' if is_windows else 'chromedriver')

print('chromedriver path: {}'.format(chromedriver_path), file = sys.stderr)

options = Options()
if profile_dir_name == None:
  profile_dir_name = 'CustomProfile'
user_data_dir = '{0}\\AppData\\Local\\Google\\Chrome\\User Data\\{1}'.format(os.getenv('USERPROFILE'), profile_dir_name) if is_windows else '{0}/.config/{1}'.format(os.getenv('HOME'), profile_dir_name)
# NOTE: the actual profile dir will be created as 
# '{os.getenv('HOME')}\\AppData\\Local\\Google\\Chrome\\User Data\\{profile_dir_name}\\{profile_dir_name}'
# with profile_dir_name twice
# NOTE: will silently fail on Windows 10 x64 Chrome 109 x86
if os.path.isdir(user_data_dir):
  print('Custom profile will be used: "{}"'.format(user_data_dir), file = sys.stderr)
else:
  print('Custom profile will be created: "{}"'.format(user_data_dir), file = sys.stderr)
# see also:
# profile switches helping with custom chrome profile
# for scraping sites that require authentication
# https://habr.com/ru/post/587708
# TODO: do 2fa on the target site with headless chrome via
# --remote-debugging-port=9222
options.add_argument('--allow-profiles-outside-user-dir')
options.add_argument('--enable-profile-shortcut-manager')
# the next argument would lead to actual profile dir to become "~/.config/CustomProfile/CustomProfile"
options.add_argument('--profile-directory={}'.format(profile_dir_name))
flush_seconds = 30
options.add_argument( '--profiling-flush={}'.format(flush_seconds))
options.add_argument('--enable-aggressive-domstorage-flushing')
options.add_argument('--disable-blink-features=AutomationControlled')
# to clear the profile simply remove the contents of your profile folder
# '~/.config/CustomProfile/Profile 1/'

# for full list of command line switches see
# https://peter.sh/experiments/chromium-command-line-switches


options.add_argument( 'user-data-dir={}'.format(user_data_dir))


user_agent = 'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0)'
if headless:
  options.add_argument('--window-size=1920,1080')
  options.add_argument('--headless')
  options.add_argument('--disable-gpu')
  options.add_argument('--enable-javascript')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--no-sandbox')
  options.add_argument('--ignore-certificate-errors')
  options.add_argument('--allow-insecure-localhost')
  options.add_argument('--allow-running-insecure-content')
  options.add_argument('--disable-browser-side-navigation')
  options.add_argument( 'user-agent={}'.format(user_agent))

try:
  driver = webdriver.Chrome(executable_path = chromedriver_path, options = options)
# TODO: Message: unknown error: Chrome failed to start: exited normally.
# unknown error: DevToolsActivePort file doesn't exist
# The process started from chrome location
# C:\Program Files\Google\Chrome\Application\chrome.exe
# is no longer running, so ChromeDriver is assuming that Chrome has crashed.
# from chromedriver / chrome version mismatch
except WebDriverException as e:
  driver = None
  print(e, file = sys.stderr)
  pass
  # TODO: catch unknown error: Could not remove old devtools port file.
  # Perhaps the given user-data-dir at ... is still
  # attached to a running Chrome or Chromium process
if driver != None:
  driver.get('chrome://version/')
  # will show both Profile Path and Command Line
  time.sleep(10)
  driver.close()
  driver.quit()
  if not os.path.isdir(user_data_dir + os.sep + 'Default' ):
    print('The profile was not created: "{}"'.format(user_data_dir), file = sys.stderr)

# on a vanilla Windows node
# PATH=%PATH%;c:\Python381;%USERPROFILE%\Downloads


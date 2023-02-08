#!/usr/bin/env python3

# based on:
# https://stackoverflow.com/questions/63599903/how-can-i-play-a-youtube-video-selenium
from __future__ import print_function
import os,sys,time,re

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import WebDriverException
from selenium.webdriver.chrome.options import Options
import getopt

headless = True
global debug
debug = False

is_windows = os.getenv('OS') != None and re.compile('.*NT').match( os.getenv('OS'))
homedir = os.getenv('USERPROFILE' if is_windows else 'HOME')

print('user home directory path: {}'.format(homedir), file = sys.stderr)

chromedriver_path = homedir + os.sep + 'Downloads' + os.sep + ('chromedriver.exe' if is_windows else 'chromedriver')

print('chromedriver path: {}'.format(chromedriver_path), file = sys.stderr)
options = Options()
options.add_argument('--allow-profiles-outside-user-dir')
options.add_argument('--enable-profile-shortcut-manager')
flush_seconds = 30
options.add_argument( '--profiling-flush={}'.format(flush_seconds))
options.add_argument('--enable-aggressive-domstorage-flushing')
options.add_argument('--disable-blink-features=AutomationControlled')

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
except WebDriverException as e:
  driver = None
  print(e, file = sys.stderr)
  pass
if driver != None:
  url = 'https://www.youtube.com/watch?v=ik6jzbW2jOE'
  
  driver.get(url)
  time.sleep(5)
  video = driver.find_element_by_id('movie_player')
  video.send_keys(Keys.SPACE)
  time.sleep(1)
  video.click()

  time.sleep(10)
  driver.close()
  driver.quit()

# on a vanilla Windows node
# PATH=%PATH%;c:\Python381;%USERPROFILE%\Downloads




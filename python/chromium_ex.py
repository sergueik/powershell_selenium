#!/usr/bin/env python3

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

from selenium.common.exceptions import TimeoutException
import getopt
from os import getenv
import sys, time, datetime

if getenv('OS') != None :
  homedir = getenv('USERPROFILE').replace('\\', '/')
  chromedriver = 'chromedriver.exe'
  # https://www.chromium.org/getting-involved/download-chromium
  # https://commondatastorage.googleapis.com/chromium-browser-snapshots/index.html?prefix=Win/98796/
  browser = (r'{}\AppData\Local\Chromium\Application\chromium.exe'.format(getenv('USERPROFILE'))) # per-user
  executable_path = r'{}\Downloads\{}'.format(getenv('USERPROFILE'), chromedriver)
else:
  homedir = getenv('HOME')
  chromedriver = 'chromedriver'
  # see also: smapshot directory
  # https://commondatastorage.googleapis.com/chromium-browser-snapshots/index.html?prefix=Linux_x64/97974/
  browser = '/usr/bin/chromium-browser'
  executable_path = '{}/Downloads/{}'.format(homedir, chromedriver)

options = Options()
options.add_argument('start-maximized')
options.binary_location = browser

# additional options
options.add_argument('--allow-insecure-localhost')
options.add_argument('--allow-running-insecure-content')
options.add_argument('--disable-blink-features=AutomationControlled')
options.add_argument('--disable-browser-side-navigation')
options.add_argument('--disable-dev-shm-usage')
options.add_argument('--disable-extensions')
options.add_argument('--disable-gpu')
options.add_argument('disable-infobars')
options.add_argument('--enable-javascript')
# options.add_argument('--headless')
options.add_argument('--ignore-certificate-errors')
options.add_argument('--no-sandbox')
options.add_argument('start-maximized')
user_agent = 'Chromium 95.0.4638.69'
# options.add_argument('--user-agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:72.0) Gecko/20100101 Firefox/72.0"')
options.add_argument('--user-agent="{}"'.format(user_agent))
options.add_argument('--window-size=1920, 1080')

driver = webdriver.Chrome( executable_path = executable_path, options = options)

# NOTE: the below does not work when browser is run headless
url = 'chrome://settings/help'
try:
  # driver.get('chrome://setings/help')
  print('navigate to {}'.format(url))
  driver.get(url = url)
  try:
    # https://selenium-python.readthedocs.io/waits.html
    title = 'Settings - About Chromium'
    print ('Wait for title {}'.format(title))
    WebDriverWait(driver,10).until(EC.title_contains(title))
    print('Page title is: "{}"'.format(driver.title), file = sys.stderr)
    print('navigated to {}'.format(driver.current_url))
    # print('page: {}'.format(driver.page_source))
    time.sleep(10)
  except (TimeoutException) as e:
    print('Unexected exception waiting for Page title change: {0}'.format(e))
    print('Actual title: {}'.format(driver.title)) # possibly blank
  # This relies on user-agent
  url = 'https://www.whatismybrowser.com'
  driver.get(url = url)
  try:
    title = 'What browser am I using?'
    print ('Wait for title {}'.format(title))
    WebDriverWait(driver,10).until(EC.title_contains(title))
    print('Page title is: "{}"'.format(driver.title), file = sys.stderr)
    print('navigated to {}'.format(driver.current_url))
    print('page: {}'.format(driver.page_source))
    time.sleep(10)
  except (TimeoutException) as e:
    print('Unexected exception waiting for Page title change: {0}'.format(e))
    print('Actual title: {}'.format(driver.title)) # possibly blank
 
except Exception as e:
  print(e)
 
finally:
  driver.close()
  driver.quit()


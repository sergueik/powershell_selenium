#!/usr/bin/env python3

# origin: https://stackoverflow.com/questions/59644818/how-to-initiate-a-chromium-based-vivaldi-browser-session-using-selenium-and-pyth

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import getopt
from os import getenv
import sys, time, datetime

if getenv('OS') != None :
  homedir = getenv('USERPROFILE').replace('\\', '/')
  chromedriver = 'chromedriver.exe'
  browser = (r'{}\AppData\Local\Vivaldi\Application\vivaldi.exe'.format(getenv('USERPROFILE'))) # per-user
  executable_path = r'{}\Downloads\{}'.format(getenv('USERPROFILE'), chromedriver)
else:
  homedir = getenv('HOME')
  chromedriver = 'chromedriver'
  browser = '/usr/bin/vivaldi'
  # place driver into individual directory to avoid collisions between chromium and vivaldi
  executable_path = '{}/Downloads/vivaldi/{}'.format(homedir, chromedriver)

# NOTE:
# Vivaldi 2.2.1388.37
# is reported to be running chrome 71:
# Current browser version is 71.0.3578.98 with binary path /usr/bin/vivaldi
# which requires
# ChromeDriver 2.46
# this combination selenium opens visible browser window but fails to navigate it anywhere
# the Vivaldi 4.1.2369 is running chrome 92.0.4515.134

options = Options()
options.add_argument('start-maximized')
options.binary_location = browser

# additional options
options.add_argument('--window-size=1920, 1080')
options.add_argument('--disable-extensions')
# options.add_argument('--headless')
options.add_argument('--disable-gpu')
#options.add_argument('--disable-dev-shm-usage')
options.add_argument('--no-sandbox')
options.add_argument('--ignore-certificate-errors')
options.add_argument('--allow-insecure-localhost')
options.add_argument('--allow-running-insecure-content')
options.add_argument('--disable-browser-side-navigation')
options.add_argument('--enable-javascript')
options.add_argument('--user-agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:72.0) Gecko/20100101 Firefox/72.0"')

driver = webdriver.Chrome( executable_path = executable_path, options = options)

url = 'https://qna.habr.com'
try:
  driver.get(url = url)
  time.sleep(1)
  print('navigated to {}'.format(driver.current_url))
 
except Exception as e:
  # selenium.common.exceptions.WebDriverException: Message: unknown error: unable to discover open pages
  print(e)
 
finally:
  driver.close()
  driver.quit()


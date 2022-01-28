# based on:
# https://stackoverflow.com/questions/57780426/selenium-headless-chrome-how-to-query-status-of-downloads
# https://stackoverflow.com/questions/45631715/downloading-with-chrome-headless-and-selenium
# See also:
# https://chromedevtools.github.io/devtools-protocol/tot/Browser/#method-setDownloadBehavior
# https://chromedevtools.github.io/devtools-protocol/tot/Page/#method-setDownloadBehavior

# https://github.com/sergueik/selenium_cdp/blob/master/src/test/java/com/github/sergueik/selenium/BrowserDownloadCdpTest.java
# https://github.com/sergueik/cdp_webdriver/blob/master/src/test/java/example/BrowserDownloadTest.java


#!/usr/bin/env python3

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

from selenium.common.exceptions import TimeoutException

import getopt
from os import getenv, remove
import sys, time, datetime
import json, base64
from os.path import exists

run_headless = False
debug = True
# https://stackoverflow.com/questions/47023842/selenium-chromedriver-printtopdf
# https://www.python-course.eu/python3_formatted_output.php
def send_command_and_get_result(driver, cmd, params = {}):
  post_url = driver.command_executor._url + '/session/{0:s}/chromium/send_command_and_get_result'.format( driver.session_id)
  if debug:
    print ('POST to {}'.format(post_url))
    print('params: {}'.format(json.dumps({'cmd': cmd, 'params': params})))

  response = driver.command_executor._request('POST', post_url, json.dumps({'cmd': cmd, 'params': params}))
  if debug:
    print( response.keys())
  # NOTE: 'has_key()' is even removed from P 3.x
  # see also: https://stackoverflow.com/questions/1323410/should-i-use-has-key-or-in-on-python-dicts
  # NOTE: KeyError: 'status'
  # early imlementation returns JSON with ['status', 'sessionId', 'value'] keys
  # with recent versions of chrome response contains only has ['value']['data']
  # print( response.keys())
  if ('status' in response ) and response['status']:
    raise Exception(response.get('value'))

  return response.get('value')
  # NOTE: on Windows 7 node occationally seeing commctl32.dll warning:
  # 'A program running on this computer is trying to display a message'
  # no meaningful message shown when 'View the Message' is chosen - repeated multiple times

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
  # for Ubuntu 18.04, apt install
  browser = '/usr/bin/chromium-browser'
  # same, with Chrome browser
  # browser = '/usr/bin/google-chrome'
  # for Ubuntu 20.04, snap install
  # https://linuxize.com/post/how-to-install-chromium-web-browser-on-ubuntu-20-04/
  
  # sudo snap install chromium
  # sudo apt install python3-pip
  # pip3 install selenium
  # pip3 install bs4
  # check and install matching version of chromedriver:
  # wget http://chromedriver.storage.googleapis.com/97.0.4692.20/chromedriver_linux64.zip
  # browser = '/snap/bin/chromium'
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
if getenv('DISPLAY') is None:
  run_headless = True
if run_headless == True:
  options.add_argument('--headless')
options.add_argument('--ignore-certificate-errors')
options.add_argument('--no-sandbox')
options.add_argument('start-maximized')
user_agent = 'Chromium 95.0.4638.69'
# https://stackoverflow.com/questions/64992087/webdriverexception-unknown-error-devtoolsactiveport-file-doesnt-exist-while-t
# ChromeDriver uses the /tmp directory to communicate with Chromium, but Snap remaps /tmp directory to a different location (specifically, to /tmp/snap.chomium/tmp). This causes errors because ChromeDriver can't find files created by Chromium. ChromeDriver is designed and tested with Google Chrome, and it may have compatibility issues with third-party distributions.

options.add_argument('--user-data-dir="{}"'.format(homedir))
options.add_argument('--remote-debugging-port=9222')

# options.add_argument('--user-agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:72.0) Gecko/20100101 Firefox/72.0"')
options.add_argument('--user-agent="{}"'.format(user_agent))
options.add_argument('--window-size=1920, 1080')

def enable_download_in_headless_chrome(driver, download_dir):
  # add missing support for chrome "send_command"  to selenium webdriver
  driver.command_executor._commands["send_command"] = ("POST", '/session/$sessionId/chromium/send_command')
  params = {
    'cmd': 'Page.setDownloadBehavior',
    'params': {'behavior': 'allow', 'downloadPath': download_dir},
  }
  return driver.execute("send_command", params)

driver = webdriver.Chrome( executable_path = executable_path, options = options)
download_dir = '/var/tmp'
try:
  cmd = 'Browser.setDownloadBehavior'
  params = {
    'behavior': 'allow', 'downloadPath': download_dir
  }

  result = send_command_and_get_result(driver, cmd, params)
  url = 'https://scholar.harvard.edu/files/torman_personal/files/samplepptx.pptx'

  print('navigate to {}'.format(url))
  driver.get(url = url)
  
  delay = 10
  print ('wait {} second'.format(delay))
  time.sleep(delay)
  if exists(download_dir + '/' + 'samplepptx.pptx'):
    print('file was downloaded to specified directory: {}'.format(download_dir))
    remove(download_dir + '/' + 'samplepptx.pptx')
    print('removed the file')
  cmd = 'Browser.setDownloadBehavior'
  params = {
    'behavior': 'default'
  }


  # test 2
  cmd = 'Page.setDownloadBehavior'
  result = send_command_and_get_result(driver, cmd, params)
  url = 'https://scholar.harvard.edu/files/torman_personal/files/samplepptx.pptx'

  print('navigate to {}'.format(url))
  driver.get(url = url)
  
  delay = 10
  print ('wait {} second'.format(delay))
  time.sleep(delay)
  if exists(download_dir + '/' + 'samplepptx.pptx'):
    print('file was downloaded to specified directory: {}'.format(download_dir))
    remove(download_dir + '/' + 'samplepptx.pptx')
    print('removed the file')
  else:
    print('file was not observed in specified directory: {}'.format(download_dir))

  cmd = 'Page.setDownloadBehavior'
  params = {
    'behavior': 'default'
  }
except Exception as e:
  print(e)
 
finally:
  driver.close()
  driver.quit()



# not recommended: does not work in headless because the chrome://downloads is not available
# for dynamic tracking of the progress see Java Selenium 4.x BIDI example
# https://github.com/sergueik/selenium_cdp/blob/master/src/test/java/com/github/sergueik/selenium/BrowserDownloadDevToolsTest.java

"""Call this after running driver.get("chrome://downloads")."""
def get_top_download_state(driver):

  [state, percent, progress] = driver.execute_script("""
  var item = downloads.Manager.get().items_[0];
  var state = item.state;
  var percent = item.percent;
  var progress = item.progressStatusText;
  return [state, percent, progress];
  """)
  return state, percent, progress


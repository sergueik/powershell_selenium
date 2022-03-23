#!/usr/bin/env python3

# based on answering the topic https://qna.habr.com/q/732307
# see also: http://www.programmersought.com/article/34791573956/

import getopt
import json, base64
from os import getenv
from os.path import exists
import re
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
from selenium.webdriver.support.ui import WebDriverWait
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.support import expected_conditions
import sys

def element_screenshot(driver,params):
  command = 'Page.captureScreenshot'
  result = send_command_and_get_result(driver, command, params)
  return result

# https://www.python-course.eu/python3_formatted_output.php
def send_command_and_get_result(driver, cmd, params = {}):
  post_url = driver.command_executor._url + '/session/{0:s}/chromium/send_command_and_get_result'.format( driver.session_id)
  if debug:
    print ('POST to {}'.format(post_url))
    print('params: {}'.format(json.dumps({'cmd': cmd, 'params': params})))

  response = driver.command_executor._request('POST', post_url, json.dumps({'cmd': cmd, 'params': params}))
  if debug:
    print( response.keys())
  return base64.b64decode(response['value']['data'])

try:
  opts, args = getopt.getopt(sys.argv[1:], 'hds:', ['help', 'debug'])
except getopt.GetoptError as err:
  print('Usage: simple_clipped_screenshot.py --debug')
  print(str(err))
  exit()

max_cnt = 10
global debug
debug = False
for option, argument in opts:
  if option == '-d':
    debug = True
  else:
    assert False, 'unhandled option: {}'.format(option)

if getenv('OS') != None :
  homedir = getenv('USERPROFILE').replace('\\', '/')
else:
  homedir = getenv('HOME')

capabilities = DesiredCapabilities.CHROME.copy()
capabilities['acceptSslCerts'] = True
capabilities['acceptInsecureCerts'] = True
# https://www.programcreek.com/python/example/96012/selenium.webdriver.common.desired_capabilities.DesiredCapabilities.CHROME
options = webdriver.ChromeOptions()
# user_agent = 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36'
# option.add_argument('--proxy-server={}'.format(proxy))
options.add_argument('--no-sandbox')
options.add_argument('--headless')
options.add_argument('--disable-gpu')
# for local tests, check if the driver is in "Downloads"
if getenv('OS') != None :
  driver_path =  homedir + '/' + 'Downloads' + '/' + 'chromedriver.exe'
else:
  driver_path =  homedir + '/' + 'Downloads' + '/' + 'chromedriver'
  # for Docker tests
  if not exists(driver_path):
    driver_path = '/usr/bin/chromedriver'

driver = webdriver.Chrome( driver_path, chrome_options = options, desired_capabilities = capabilities)

url = 'https://www.google.com/'
if debug:
  print('Loading url: "{}"'.format(url), file = sys.stderr)
driver.get(url)
element = driver.find_elements_by_css_selector('img[alt = "Google"]')[0]
params = {'clip': {
  'x': element.location['x'],
  'y': element.location['y'],
  'width': element.size['width'],
  'height': element.size['height'],
  'scale': 1
}}
result = element_screenshot(driver, params)
output_file = 'logo_screenshot.png'
with open(output_file, 'wb') as f:
  f.write(result)
with open(file = f'logo_screenshot_2.png', mode = 'wb') as f:
  f.write(element.screenshot_as_png)

# NOTE: Google logo screenshot gets a fragment of "sign in to Google" popup
driver.close()
driver.quit()


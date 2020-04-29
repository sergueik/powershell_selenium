#!/usr/bin/env python3

# Copyright (c) 2020 Serguei Kouzmine
#
# used to answer the quesion https://software-testing.ru/forum/index.php?/topic/38904-kak-zadat-geolokatciiu-dlia-okna-chromedriver-selenium-python/ (in Russian)
from __future__ import print_function
import getopt
import re
from os import getenv
import time
import sys
from selenium.common.exceptions import TimeoutException
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions
from selenium.webdriver.support.ui import WebDriverWait
import json, base64

def send_command(driver, cmd, params = {}):
  post_url = driver.command_executor._url + '/session/{0:s}/chromium/send_command_and_get_result'.format( driver.session_id)
  response = driver.command_executor._request('POST', post_url, json.dumps({'cmd': cmd, 'params': params}))
  if ('status' in response ) and response['status']:
    raise Exception(response.get('value'))

if __name__ == '__main__':
  try:
    opts, args = getopt.getopt(sys.argv[1:], 'hds:u:', ['help', 'debug', 'scale=', 'url='])
  except getopt.GetoptError as err:
    print('usage: page_cdp_scale.py --scale <scale> --url <url>')
    print(str(err))
    exit()

  url = None
  scale = None
  global debug
  debug = False
  for option, argument in opts:
    if option == '-d':
      debug = True
    elif option in ('-h', '--help'):
      print ('usage: page_cdp_scale.py --url <html page> --scale <scale>')
      # e.g. python3 page_cdp_scale.py --url https://www.google.com/maps --scale 1.25

      exit()
    elif option in ('-u', '--url'):
      url = argument
    elif option in ('-s', '--scale'):
      scale = argument
    else:
      assert False, 'unhandled option: {}'.format(option)
  if url == None or scale == None:
    print('usage: page_cdp_scale.py --scale <scale> --url <url>')
    exit()
  match = re.match(r'^(https?://).*$', url, re.UNICODE)
  if match == None:
    url = 'https://{}'.format(url)

  if getenv('OS') != None :
    homedir = getenv('USERPROFILE').replace('\\', '/')
  else:
    homedir = getenv('HOME')

  options = Options()
  driver = webdriver.Chrome( homedir + '/' + 'Downloads' + '/' + 'chromedriver', options = options)

  driver.get(url)
  send_command(driver, 'Emulation.resetPageScaleFactor')
  time.sleep(10)
  # does not work well with scale factors under 1
  params = {
    'pageScaleFactor': float(scale)
  }
  # https://chromedevtools.github.io/devtools-protocol/tot/Emulation/#method-setPageScaleFactor
  send_command(driver, 'Emulation.setPageScaleFactor', params)
  # https://chromedevtools.github.io/devtools-protocol/tot/Emulation/#method-resetPageScaleFactor

  time.sleep(10)
  send_command(driver, 'Emulation.resetPageScaleFactor')
  time.sleep(3)
  driver.quit()

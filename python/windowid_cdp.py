#!/usr/bin/env python3

# Copyright (c) 2022 Serguei Kouzmine
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

def send_command_return_result(driver, cmd, params = {}, resultkey = 'windowId'):
  post_url = driver.command_executor._url + '/session/{0:s}/chromium/send_command_and_get_result'.format( driver.session_id)
  response = driver.command_executor._request('POST', post_url, json.dumps({'cmd': cmd, 'params': params}))
  print('response: {}'.format(response))
  if ('status' in response ) and response['status']:
    raise Exception(response.get('value'))
  return response.get('value').get(resultkey)
   
def send_command(driver, cmd, params = {}):
  post_url = driver.command_executor._url + '/session/{0:s}/chromium/send_command_and_get_result'.format( driver.session_id)
  response = driver.command_executor._request('POST', post_url, json.dumps({'cmd': cmd, 'params': params}))
  if ('status' in response ) and response['status']:
    raise Exception(response.get('value'))
   
if __name__ == '__main__':
  try:
    opts, args = getopt.getopt(sys.argv[1:], 'hdW:H:u:', ['help', 'debug', 'width=', 'height=', 'url='])
  except getopt.GetoptError as err:
    print('usage: page_cdp_scale.py --scale <scale> --url <url>')
    print(str(err))
    exit()

  url = None
  width = None
  height = None
  global debug
  debug = False
  for option, argument in opts:
    if option == '-d':
      debug = True
    elif option in ('-h', '--help'):
      print ('usage: page_cdp_scale.py --url <html page> --width <width> --height <height>')
      # e.g. python3 windowid_cdp.py --width 400 --height 300 --url https://www.wikipedia.org

      exit()
    elif option in ('-u', '--url'):
      url = argument
    elif option in ('-W', '--width'):
      width = int(argument)
    elif option in ('-H', '--height'):
      height = int(argument)
    else:
      assert False, 'unhandled option: {}'.format(option)
  if url == None or width == None or height == None: 
    print('usage: page_cdp_scale.py --url <html page> --width <width> --height <height>')
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
  
  # a.k.a. "puppeteer solution"
  windowId = send_command_return_result(driver,'Browser.getWindowForTarget', {}, 'windowId')
  print('windowId: {}'.format(windowId))
  print('width: {}'.format(width))
  print('height: {}'.format(height))
  # width = 400
  # height = 300 
  time.sleep(10)
  params = {
    'windowId': windowId,
    'windowState': 'normal', 
    'bounds': {
      'left': 0, 'top': 0,
      'width': width, 'height': height
    }
  }
  # a.k.a. "puppeteer solution"
  send_command(driver,'Browser.setWindowBounds', params)

  time.sleep(10)
  driver.quit()

#!/usr/bin/env python3

# Copyright (c) 2020 Serguei Kouzmine
#
# used to answer the quesion https://software-testing.ru/forum/index.php?/topic/38904-kak-zadat-geolokatciiu-dlia-okna-chromedriver-selenium-python/ (in Russian)
from __future__ import print_function
import time
import sys
from os import getenv
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.support import expected_conditions
import json, base64

def send_command(driver, cmd, params = {}):
  post_url = driver.command_executor._url + '/session/{0:s}/chromium/send_command_and_get_result'.format( driver.session_id)
  print ('POST to {}'.format(post_url))
  print('params: {}'.format(json.dumps({'cmd': cmd, 'params': params})))
  # see also: https://github.com/SeleniumHQ/selenium/blob/cdp_codegen/dotnet/src/webdriver/Chromium/ChromiumDriver.cs#L69
  response = driver.command_executor._request('POST', post_url, json.dumps({'cmd': cmd, 'params': params}))
  if ('status' in response ) and response['status']:
    raise Exception(response.get('value'))

if __name__ == '__main__':
  if getenv('OS') != None :
    homedir = getenv('USERPROFILE').replace('\\', '/')
  else:
    homedir = getenv('HOME')

  options = Options()
  driver = webdriver.Chrome( homedir + '/' + 'Downloads' + '/' + 'chromedriver', options = options)
  latitude = 37.422290
  longitude = -122.084057
  latitude = 55.7039
  longitude = 37.5287
  params = {
    'latitude': latitude,
    'longitude': longitude,
    'accuracy': 100,
  }
  url = 'https://www.google.com/maps'

  print('Loading url: "{}"'.format(url), file = sys.stderr)
  driver.get(url)

  WebDriverWait(driver, 120).until( expected_conditions.presence_of_element_located((By.ID,'widget-mylocation')))
  # NOTE: frequent cast error:
  # TypeError: __init__() takes 2 positional arguments but 3 were given

  # time.sleep(10)
  print('params: {}'.format(params))

  # https://chromedevtools.github.io/devtools-protocol/tot/Emulation#method-setGeolocationOverride
  send_command(driver, 'Emulation.setGeolocationOverride', params)
  try:
    element = WebDriverWait(driver, 120).until( expected_conditions.visibility_of(driver.find_element_by_css_selector('div[class *= "widget-mylocation-button-icon-common"]')))
    # NOTE: this wait methos appears less reliable then xxx_located method

    if element != None:
      element.click()
  except TimeoutException:
    pass

  time.sleep(10)
  driver.quit()


#!/usr/bin/env python3

# Copyright (c) 2020,2022 Serguei Kouzmine
from __future__ import print_function
import getopt
import re
import sys
import time
import json, base64
from os import getenv
from selenium.common.exceptions import TimeoutException
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support import expected_conditions
from selenium.webdriver.support.ui import WebDriverWait

if __name__ == '__main__':
  try:
    opts, args = getopt.getopt(sys.argv[1:], 'hdz:u:', ['help', 'debug', 'zoom=', 'url='])
  except getopt.GetoptError as err:
    print('usage: page_script_zoom.py --zoom <zoom> --url <url>')
    print(str(err))
    exit()

  url = None
  zoom = None
  global debug
  debug = False
  for option, argument in opts:
    if option == '-d':
      debug = True
    elif option in ('-h', '--help'):
      print ('usage: page_script_zoom.py --url <html page> --zoom <zoom>')
      # e.g. python3 page_script_zoom.py --url https://www.google.com/maps --zoom 3

      exit()
    elif option in ('-u', '--url'):
      url = argument
    elif option in ('-z', '--zoom'):
      zoom = float(argument)
    else:
      assert False, 'unhandled option: {}'.format(option)
  if url == None or zoom == None:
    print('usage: page_script_zoom.py --zoom <zoom> --url <url>')
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
  wait = WebDriverWait(driver, 10)
  wait.until(expected_conditions.presence_of_element_located((By.CSS_SELECTOR, 'div.central-textlogo > img')))
  # for google, 'div.h-c-header__company-logo img'
  element = driver.find_element_by_tag_name('body')

  driver.execute_script('document.body.style.zoom = "{}%"'.format(int(100 * zoom)))
  time.sleep(3)
  # NOTE: to zoom back, no need to recalculate 100/zoom, just a 100%

  driver.execute_script('document.body.style.zoom = "100%"')
  time.sleep(3)
  driver.close()
  driver.quit()

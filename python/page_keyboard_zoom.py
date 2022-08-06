#!/usr/bin/env python3

# Copyright (c) 2020,2022 Serguei Kouzmine
# https://stackoverflow.com/questions/28111539/can-we-zoom-the-browser-window-in-python-selenium-webdriver
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
# alternatively
import keyboard
# see https://qna.habr.com/q/1185190
if __name__ == '__main__':
  try:
    opts, args = getopt.getopt(sys.argv[1:], 'hdz:u:', ['help', 'debug', 'zoom=', 'url='])
  except getopt.GetoptError as err:
    print('usage: page_keyboard_zoom.py --zoom <zoom> --url <url>')
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
      print ('usage: page_keyboard_zoom.py --url <html page> --zoom <zoom>')
      # e.g. python3 page_keyboard_zoom.py --url https://www.wikipedia.org/ --zoom .25

      exit()
    elif option in ('-u', '--url'):
      url = argument
    elif option in ('-z', '--zoom'):
      zoom = argument
    else:
      assert False, 'unhandled option: {}'.format(option)
  if url == None or zoom == None:
    print('usage: page_keyboard_zoom.py --zoom <zoom> --url <url>')
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
  # does not work, left the exerise of detecting the need to zoom in or out for now
  element.send_keys(Keys.LEFT_CONTROL + Keys.ADD)
  # Keys.CONTROL + '+'  does not work
  time.sleep(3)
  element.send_keys(Keys.CONTROL + '+' + Keys.CONTROL )
  # Keys.CONTROL + '+'  does not work
  time.sleep(3)
  element.send_keys(Keys.CONTROL + '-')
  time.sleep(3)

  # NOTE: on Ubuntu regardless how 'keyboard' module installed locally or globally
  # sudo -H pip3 install keyboard
  # running the script fails with
  # ImportError: You must be root to use this library on linux.
  # (code commented)
  if False:
    keyboard.press('ctrl')
    keyboard.send('-')
    keyboard.release('ctrl')
    time.sleep(3)
  driver.close()
  driver.quit()

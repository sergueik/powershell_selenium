#!/usr/bin/env python3

import getopt
import sys
import re
from os import getenv
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import json, base64
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.support import expected_conditions
from datetime import date

try:
  opts, args = getopt.getopt(sys.argv[1:], 'hdi:o:s:p:', ['help', 'debug','size='])
except getopt.GetoptError as err:
  print('usage:card_set_screehsnot.py --size <number of cards> --debug')
  print(str(err))
  exit()

max_cnt = 10
global debug
debug = False
for option, argument in opts:
  if option == '-d':
    debug = True
  elif option in ('-s', '--size'):
    max_cnt = int(argument)
  else:
    assert False, 'unhandled option: {}'.format(option)

if getenv('OS') != None :
  homedir = getenv('USERPROFILE').replace('\\', '/')
else:
  homedir = getenv('HOME')
options = Options()
options.add_argument('--headless')
options.add_argument('--disable-gpu')
driver = webdriver.Chrome(homedir + '/' + 'Downloads' + '/' + 'chromedriver', options = options)
year,month,day = date.today().year, date.today().month, date.today().day
url = 'http://almetpt.ru/{}/site/schedulegroups/0/1/{}-{}-{}'.format(year,year,'{0:02d}'.format(month),'{0:02d}'.format(day))
if debug:
  print('Loading url: "{}"'.format(url), file = sys.stderr)
driver.get(url)
try:
  # https://selenium-python.readthedocs.io/waits.html
  element = WebDriverWait(driver, 10).until( expected_conditions.visibility_of(driver.find_element_by_xpath('//div[@class="card-columns"]')))
  if element != None:
    print( element.get_attribute('innerHTML'))
except TimeoutException:
  pass
# https://selenium-python.readthedocs.io/locating-elements.html
cards = driver.find_elements_by_xpath('//div[@class="card-columns"]//div[contains(@class, "card")][div[contains(@class, "card-header")]]')
cnt = 0
for card in cards:
  cnt += 1
  if cnt > max_cnt:
    break
  params = {'clip': {
    'x': card.location['x'],
    'y': card.location['y'],
    'width': card.size['width'],
    'height': card.size['height'],
    'scale': '1'
  }}
  print("card element {}: {}".format(cnt,params))
driver.close()
driver.quit()

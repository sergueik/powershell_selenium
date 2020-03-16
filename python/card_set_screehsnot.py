#!/usr/bin/env python3

# based on https://qna.habr.com/q/732307

import getopt
from datetime import date
import json, base64
from os import getenv
import re
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
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
  opts, args = getopt.getopt(sys.argv[1:], 'hds:', ['help', 'debug','size='])
except getopt.GetoptError as err:
  print('Usage: card_set_screehsnot.py --size <number of cards> --debug')
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
    'scale': 1
  }}
  print(f'card element {cnt}')
  result = element_screenshot(driver,params)
  with open('card_1_{}.png'.format(cnt), 'wb') as output_file:
    output_file.write(result)
  with open(file = f'card_2_{cnt}.png', mode = 'wb') as output_file:
    output_file.write(card.screenshot_as_png)

# alternative locator
cards = driver.find_elements_by_xpath('//*[contains(@class, "d-inline-block")]')
for cnt, card in enumerate(cards):
  if cnt > max_cnt:
    break
  with open(file = f'card_3_{cnt}.png', mode = 'wb') as output_file:
    output_file.write(card.screenshot_as_png)
driver.close()
driver.quit()

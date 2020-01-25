#!/usr/bin/env python
# based on: https://habr.com/ru/post/459112 (in Russian)
# failing with certain builds of google-chrome-stable 77
# - a tiny blank pdf is produced
# NOTE: works with chromium-browser 79 and google-chrome-stable 76 and 72
import sys
from os import getenv
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import json, base64

def print_pdf(path, chromedriver = './chromedriver', print_options = {}):
  options = Options()
  options.add_argument('--headless')
  options.add_argument('--disable-gpu')
  driver = webdriver.Chrome(chromedriver, options = options)
  driver.get(path)
  params = {
    'landscape': False,
    'displayHeaderFooter': False,
    'printBackground': True,
    'preferCSSPageSize': True,
  }
  params.update(print_options)
  result = send_command_and_get_result(driver, 'Page.printToPDF', params)
  # print( result.keys())
  driver.quit()
  return base64.b64decode(result['data'])

def send_command_and_get_result(driver, cmd, params = {}):
  # https://www.python-course.eu/python3_formatted_output.php
  response = driver.command_executor._request('POST', driver.command_executor._url + '/session/{0:s}/chromium/send_command_and_get_result'.format( driver.session_id), json.dumps({'cmd': cmd, 'params': params}))
  # NOTE: 'has_key()' is even removed from P 3.x
  # see also: https://stackoverflow.com/questions/1323410/should-i-use-has-key-or-in-on-python-dicts
  # NOTE: KeyError: 'status'
  # early imlementation returns JSON with ['status', 'sessionId', 'value'] keys
  # with recent versions of chrome response contains only has ['value']['data']
  # print( response.keys())
  if ('status' in response ) and response['status']:
    raise Exception(response.get('value'))
  return response.get('value')

if __name__ == '__main__':
  if len(sys.argv) != 3:
    print ('usage: print_pdf.py <html page> <output file>')
    exit()
  if getenv('OS') != None :
    homedir = getenv('HOMEDIR').replace('\\', '/')
  else:
    homedir = getenv('HOME')
  result = print_pdf(sys.argv[1], homedir + '/' + 'Downloads' + '/' + 'chromedriver')
  with open(sys.argv[2], 'wb') as file:
    file.write(result)


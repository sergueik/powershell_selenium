#!/usr/bin/env python3
# based on: https://habr.com/ru/post/459112 (in Russian)
# see also: https://github.com/SeleniumHQ/selenium/blob/master/dotnet/src/webdriver/Chromium/ChromiumDriver.cs
# https://github.com/checkly/puppeteer-examples/blob/master/1. basics/pdf.js

# NOTE: failing with certain builds of google-chrome-stable 77
# - a tiny blank pdf is produced
# works with chromium-browser 79 and google-chrome-stable 76 and 72
# with google-chrome 76 the PrintToPDF API is only supported in headless mode.
# the "PrintToPDF is not implemented" exception is returned when run fullscreen

from __future__ import print_function
import getopt
import sys
import re
from os import getenv
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import json, base64

def print_pdf(url, chromedriver = './chromedriver', print_options = {}):
  options = Options()
  options.add_argument('--headless')
  options.add_argument('--disable-gpu')
  driver = webdriver.Chrome(chromedriver, options = options)
  if debug:
    print('Loading url: "{}"'.format(url), file = sys.stderr)

  driver.get(url)
  params = {
    'landscape': False,
    'displayHeaderFooter': False,
    'printBackground': True,
    'preferCSSPageSize': False,
  }
  params.update(print_options)
  if debug:
    print('params: {}'.format(params))
  result = send_command_and_get_result(driver, 'Page.printToPDF', params)
  # print( result.keys())
  driver.quit()
  return base64.b64decode(result['data'])

def send_command_and_get_result(driver, cmd, params = {}):
  # DevTools listening on ws://127.0.0.1:49536/devtools/browser/f77c331d-d2ef-4500-b0c0-857b8dc98984
  # "/session/{sessionId}/chromium/send_command_and_get_result"
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
  # NOTE: on Windows 7 node occationally seeing commctl32.dll warning:
  # 'A program running on this computer is trying to display a message'
  # no meaningful message shown when 'View the Message' is chosen - repeated multiple times

if __name__ == '__main__':
  # https://docs.python.org/2/library/getopt.html
  try:
    opts, args = getopt.getopt(sys.argv[1:], 'hdi:o:s:p:', ['help', 'input=', 'output=','size=', 'pages='])
  except getopt.GetoptError as err:
    print('usage: print_pdf.py --input <html page> --output <output file>')
    print(str(err))
    exit()

  output_file = None
  url = None
  size = None
  pages = None
  global debug
  debug = False
  for option, argument in opts:
    if option == '-d':
      debug = True
    elif option in ('-h', '--help'):
      print ('usage: print_pdf.py --input <html page> --output <output file>')
      exit()
    elif option in ('-i', '--input'):
      url = argument
    elif option in ('-p', '--pages'):
      pages = argument
    elif option in ('-s', '--size'):
      size = argument
    elif option in ('-o', '--output'):
      output_file = argument
    else:
      assert False, 'unhandled option: {}'.format(option)

  if url == None or output_file == None:
    print ('usage: print_pdf.py --input <html page> --output <output file>')
    exit()

  if getenv('OS') != None :
    homedir = getenv('USERPROFILE').replace('\\', '/')
  else:
    homedir = getenv('HOME')

  # NOTE:  when schema prefix is omitted from the url, an exception is raised:
  # selenium.common.exceptions.InvalidArgumentException:
  # Message: invalid argument (Session info: headless chrome=76.0.3809.100)
  match = re.match(r'^(https?://).*$', url, re.UNICODE)
  if match == None:
    url = 'https://{}'.format(url)

  match = None
  if size != None:
    match = re.match(r'a4', size, re.UNICODE|re.IGNORECASE  )
  if match == None:
    print_options = {}
  else:
    # specify custom page size (default is Letter), through dimensions
    print_options = {
      'paperWidth': 8.27,
      'paperHeight': 11.69,
    }
  if pages != None:
      print_options.update({'pageRanges': pages})
  if debug:
    print('opts: {}'.format(opts))
    # exit()
  result = print_pdf(url, homedir + '/' + 'Downloads' + '/' + 'chromedriver', print_options)
  with open(output_file, 'wb') as file:
    file.write(result)

# on vanilla Windows node
# path=%path%;c:\Python27
# path=%path%;c:\Users\sergueik\Downloads



#!/usr/bin/env python3
# based on: https://habr.com/ru/post/459112 (in Russian)
# https://stackoverflow.com/questions/47023842/selenium-chromedriver-printtopdf
# see also: https://github.com/SeleniumHQ/selenium/blob/master/dotnet/src/webdriver/Chromium/ChromiumDriver.cs
# https://github.com/checkly/puppeteer-examples/blob/master/1. basics/pdf.js

# NOTE: was found randomly failing with certain builds of google-chrome-stable 77
# intermittent issue of a tiny blank pdf produced (not saved)
# work fine  with other vesions e.g.
# chromium-browser 79 and google-chrome-stable 76 and 72
# with google-chrome 76 the PrintToPDF API is only supported in headless mode.
# 'PrintToPDF is not implemented' exception is generated when run fullscreen
# On Windows 10 / Windows Server 2016 the altenative solution would be
# 'Microsoft Print to PDF' printer-based:
# https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/sending-powershell-results-to-pdf-part-1
# https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/sending-powershell-results-to-pdf-part-2
# https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/sending-powershell-results-to-pdf-part-3
# https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/sending-powershell-results-to-pdf-part-4
# older Windows-only solutions involve "itextsharp.dll"
# https://social.technet.microsoft.com/wiki/contents/articles/30427.creating-pdf-files-using-powershell.aspx
# and pdfsharp.dll
# https://merill.net/2013/06/creating-pdf-files-dynamically-with-powershell/
# https://github.com/empira/PDFsharp
# http://forum.oszone.net/thread-344427.html (in Russian) focused on Poowershell solitions

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
  # for annotated list of chrome headless flags, see
  # https://peter.sh/experiments/chromium-command-line-switches/
  # https://groups.google.com/forum/#!topic/selenium-users/SnxpvG8Erj4
  flags = [
    '--data-path=/tmp/data-path',
    '--disable-background-timer-throttling',
    '--disable-breakpad',
    '--disable-client-side-phishing-detection',
    '--disable-cloud-import',
    '--disable-default-apps',
    '--disable-dev-shm-usage', 
    '--disable-extensions',
    '--disable-gesture-typing',
    '--disable-gpu',
    '--disable-hang-monitor',
    '--disable-infobars',
    '--disable-notifications',
    '--disable-offer-store-unmasked-wallet-cards',
    '--disable-offer-upload-credit-cards',
    '--disable-popup-blocking',
    '--disable-print-preview',
    '--disable-prompt-on-repost',
    '--disable-setuid-sandbox',
    '--disable-speech-api',
    '--disable-sync',
    '--disable-tab-for-desktop-share',
    '--disable-translate',
    '--disable-voice-input',
    '--disable-wake-on-wifi',
    '--disable-webgl',
    '--disk-cache-dir=/tmp/cache-dir',
    '--enable-async-dns',
    '--enable-simple-cache-backend',
    '--enable-tcp-fast-open',
    '--headless',
    '--hide-scrollbars',
    '--homedir=/tmp',
    '--ignore-gpu-blacklist',
    '--media-cache-size=33554432',
    '--metrics-recording-only',
    '--mute-audio',
    '--no-default-browser-check',
    '--no-first-run',
    '--no-pings',
    '--no-sandbox',
    '--no-zygote',
    '--password-store=basic',
    '--prerender-from-omnibox=disabled',
    '--remote-debugging-port=9222',
    '--single-process',
    '--use-mock-keychain',
    '--user-data-dir=/tmp/user-data',
    '--window-size={}'.format(getenv('WINDOW_SIZE'))
  ]
  
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

# https://stackoverflow.com/questions/47023842/selenium-chromedriver-printtopdf
# https://www.python-course.eu/python3_formatted_output.php
def send_command_and_get_result(driver, cmd, params = {}):
  post_url = driver.command_executor._url + '/session/{0:s}/chromium/send_command_and_get_result'.format( driver.session_id)
  if debug:
    print ('POST to {}'.format(post_url))
    print('params: {}'.format(json.dumps({'cmd': cmd, 'params': params})))

  response = driver.command_executor._request('POST', post_url, json.dumps({'cmd': cmd, 'params': params}))
  if debug:
    print( response.keys())
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
    opts, args = getopt.getopt(sys.argv[1:], 'hdi:o:s:p:', ['help', 'debug', 'input=', 'output=','size=', 'pages='])
  except getopt.GetoptError as err:
    print('usage: print_pdf.py --input <html page> --output <output file>')
    print(str(err))
    exit()

  output_file = None
  url = None
  paper_size = None
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
      paper_size = argument
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
  if paper_size != None:
    match = re.match(r'a4', paper_size, re.UNICODE|re.IGNORECASE  )
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
  with open(file = output_file, mode = 'wb') as f:
    f.write(result)

# on vanilla Windows node
# PATH=%PATH%;c:\Python27;%USERPROFILE%\Downloads




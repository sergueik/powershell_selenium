#!/usr/bin/env python
# origin: https://habr.com/ru/post/459112 (in Russian)

import sys
from os import getenv
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import json, base64

def get_pdf_from_html(path, chromedriver = './chromedriver', print_options = {}):
  webdriver_options = Options()
  webdriver_options.add_argument('--headless')
  webdriver_options.add_argument('--disable-gpu')
  driver = webdriver.Chrome(chromedriver, options = webdriver_options)

  driver.get(path)

  calculated_print_options = {
    'landscape': False,
    'displayHeaderFooter': False,
    'printBackground': True,
    'preferCSSPageSize': True,
  }
  calculated_print_options.update(print_options)

  result = send_devtools(driver, "Page.printToPDF", calculated_print_options)
  driver.quit()
  return base64.b64decode(result['data'])

def send_devtools(driver, cmd, params={}):
  resource = "/session/%s/chromium/send_command_and_get_result" % driver.session_id
  url = driver.command_executor._url + resource
  body = json.dumps({'cmd': cmd, 'params': params})
  response = driver.command_executor._request('POST', url, body)
  if response['status']:
    raise Exception(response.get('value'))
  return response.get('value')

if __name__ == "__main__":
  if len(sys.argv) != 3:
    print ("usage: converter.py <html_page_sourse> <filename_to_save>")
    exit()
  if getenv('OS') != None :
    homedir = getenv('HOMEDIR').replace('\\', '/')
  else:
    homedir = getenv('HOME')
#    opts.add_argument('--user-data-dir=' + homedir )
  result = get_pdf_from_html(sys.argv[1], homedir + '/' + 'Downloads' + '/' + 'chromedriver')
  with open(sys.argv[2], 'wb') as file:
    file.write(result)


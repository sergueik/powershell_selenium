#!/usr/bin/env python

# based on: https://habr.com/ru/post/459112 (in Russian)
# see also: https://peter.sh/experiments/chromium-command-line-switches/
# (outdated) https://www.programcreek.com/python/example/100025/selenium.webdriver.ChromeOptions
# for chromium-browser see https://stackoverflow.com/questions/16806961/testing-with-chromium-using-selenium-and-python

from __future__ import print_function
import sys
import re
import time
from os import getenv, path
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import json, base64

def download_pdf(url, xpath, download_dir, chromedrivr_path):
  options = Options()
  prefs = {'safebrowsing.enabled': True,
  'select_file_dialogs.allowed': False,
  'download.prompt_for_download': False,
  'download.directory_upgrade': True,
  'profile.default_content_setting_values.automatic_downloads': 1,
  'download_restrictions': 0,
  'profile.default_content_settings.popups': 0,
  'download.default_directory': download_dir,
  'profile.default_content_settings.popups': 0,
  'download.prompt_for_download': False,
  'credentials_enable_service': False,
  'plugins.always_open_pdf_externally': True,
  'profile.password_manager_enabled': False
  }

  options.add_experimental_option('prefs', prefs)
  options.add_argument('--disable-extensions')
  options.add_argument('--disable-infobars')
  options.add_argument('--safebrowsing-disable-extension-blacklist')
  options.add_argument('--safebrowsing-disable-download-protection')
  global driver
  if chromedriver_path:
    driver = webdriver.Chrome(chromedriver_path, chrome_options = options)
  else:
    driver = webdriver.Chrome(chrome_options = options)

  if url:
    driver.get(url )
  else:
    if getenv('OS') != None :
      homedir = getenv('USERPROFILE').replace('\\', '/')
    else:
      homedir = getenv('HOME')
    location = 'file:///{0}/{1}'.format('{0}/Downloads'.format(homedir), 'download.html')
    script_dir = path.dirname(path.realpath(__file__))
    test_file_path = script_dir + '/download.html'
    location = 'file://{0}'.format( test_file_path )
    driver.get(location)
  link = driver.find_element_by_css_selector('a')
  link.click()
  time.sleep(10)
  driver.close()
  driver.quit()
if __name__ == '__main__':
  if (len(sys.argv) != 3) and (len(sys.argv) !=1):
    print ('usage: download_pdf.py <html page> <xpath>')
    exit()
  if getenv('OS') != None :
    homedir = getenv('USERPROFILE').replace('\\', '/')
  else:
    homedir = getenv('HOME')
  # url = sys.argv[1]
  # css_selector = sys.argv[2]
  url = None
  css_selecor = None
  if url:
    match = re.match(r'^(https?://).*$', url, re.UNICODE)
    if match == None:
      url = 'https://{}'.format(url)

  chromedriver_path =  homedir + '/' + 'Downloads' + '/' + 'chromedriver'

  result = download_pdf(None, None, homedir + '/' + 'Downloads', chromedriver_path  )

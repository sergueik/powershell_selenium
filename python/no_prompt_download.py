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

default_downloads_dir = getenv('USERPROFILE' if getenv('OS') == 'NT' else 'HOME') + '/' + 'Downloads'

def download_pdf(
  url = None,
  xpath = None,
  chromedriver_path = default_downloads_dir + '/' + ('chromedriver.exe' if getenv('OS') == 'NT' else 'chromedriver'),
  download_dir = default_downloads_dir ):
  options = Options()
  prefs = {
  'safebrowsing.enabled': True,
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
  if url is None:
    url ='file://{0}'.format(path.dirname(path.realpath(__file__)) + '/'  + 'download.html' )
  if xpath is None:
    xpath = '//a'
  driver.get(url)
  link = driver.find_element_by_xpath(xpath)
  link.click()
  time.sleep(10)
  driver.close()
  driver.quit()
if __name__ == '__main__':
  if (len(sys.argv) != 3) and (len(sys.argv) !=1):
    print ('usage: download_pdf.py <html page> <xpath>')
    exit()
  if len(sys.argv) == 3:
    url = sys.argv[1]
    xpath = sys.argv[2]
    match = re.match(r'^(https?://).*$', url, re.UNICODE)
    if match == None:
      url = 'https://{}'.format(url)
  else:
    url = None
    xpath = None
  result = download_pdf( url, xpath  )

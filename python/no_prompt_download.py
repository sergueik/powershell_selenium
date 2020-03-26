#!/usr/bin/env python

# based on: https://habr.com/ru/post/459112 (in Russian)
# see also: https://peter.sh/experiments/chromium-command-line-switches/
# (outdated) https://www.programcreek.com/python/example/100025/selenium.webdriver.ChromeOptions
# for chromium-browser see https://stackoverflow.com/questions/16806961/testing-with-chromium-using-selenium-and-python

from __future__ import print_function
import sys
import re
import os
import time
from os import getenv, path
from selenium import webdriver
from selenium.webdriver.chrome.options import Options

is_windows = getenv('OS') != None and re.compile('.*NT').match( getenv('OS'))
homedir = getenv('USERPROFILE' if is_windows else 'HOME')
default_downloads_dir = homedir + os.sep + 'Downloads'

def download_pdf(
  url = None,
  xpath = None,
  chromedriver_path = default_downloads_dir + os.sep + ('chromedriver.exe' if is_windows  else 'chromedriver'),
  download_dir = default_downloads_dir ):
  options = Options()
  prefs = {
    'download.prompt_for_download': False,
    'profile.default_content_setting_values.automatic_downloads': 1,
    'download.default_directory': download_dir,
    'download.prompt_for_download': False,
    'plugins.always_open_pdf_externally': True,
    # NOTE: "plugins.plugins_list" has no effect with Chrome 65+
    'plugins.plugins_list': [{
      'enabled': False,
      'name': 'Chrome PDF Viewer'
    }]
  }

  options.add_experimental_option('prefs', prefs)
  global driver
  driver = webdriver.Chrome(chromedriver_path, chrome_options = options)
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
    ''' example:
     python no_prompt_download.py "https://intellipaat.com/blog/tutorial/selenium-tutorial/selenium-cheat-sheet/" "//*[@id=\"global\"]//a[contains(@href, \"Selenium-Cheat-Sheet.pdf\")]"
    '''
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

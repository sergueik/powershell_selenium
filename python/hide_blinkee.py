#!/usr/bin/env python

# based on https://qna.habr.com/q/778499

from __future__ import print_function
import sys
import re
import os
import time
from os import getenv, path
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.common.exceptions import ElementNotInteractableException
is_windows = getenv('OS') != None and re.compile('.*NT').match( getenv('OS'))
homedir = getenv('USERPROFILE' if is_windows else 'HOME')
default_downloads_dir = homedir + os.sep + 'Downloads'

def open_url(
  url = None,
  timeout = None,
  disable_everything = None,
  chromedriver_path = default_downloads_dir + os.sep + ('chromedriver.exe' if is_windows  else 'chromedriver')
  ):
  options = Options()
  prefs = {
    'profile.managed_default_content_settings.javascript': 2,
    'profile.managed_default_content_settings.images': 2,
    'profile.managed_default_content_settings.mixed_script': 2,
    'profile.managed_default_content_settings.media_stream': 2,
    'profile.managed_default_content_settings.stylesheets':2
  }

  options.add_argument('--disable_everything-gpu')
  options.add_argument('--enable-javascript')
  options.add_argument('--disable_everything-dev-shm-usage')
  options.add_argument('--no-sandbox')
  options.add_argument('--ignore-certificate-errors')
  options.add_argument('--allow-insecure-localhost')
  options.add_argument('--allow-running-insecure-content')
  options.add_argument('--disable_everything-browser-side-navigation')
  if ( disable_everything is None ) or (    disable_everything.lower() in ['false', '0', 'no'] ) :
    options.add_experimental_option('prefs', prefs)
  global driver
  driver = webdriver.Chrome(chromedriver_path, chrome_options = options)
  if url is None:
    url = 'https://blinkee.com'
  if timeout is None:
    timeout = 3
  driver.get(url)

  # will not see chat with Matt, it may be in iframe
  # <span id="shortMessage">Chat with Matt</span>
  # xpath = '//span[@id="shortMessage"]'

  # when js styles and images are disabled, 
  # page is totally blank and nothing is visible

  xpath = '//img[@class="theme_logo"]'
  element = driver.find_element_by_xpath(xpath)
  data = element.get_attribute('outerHTML')
  try:
    element.click()
    print ('Element {} was clickable'.format(data))
  except ElementNotInteractableException,e :
    print('Exception, ignoring: {0}'.format(e))
    print ('Element {} was not clickable'.format(data))

  time.sleep(float(timeout))
  driver.close()
  driver.quit()
		
# site picked from https://blog.rankingbyseo.com/bad-websites/ winner list
# and https://www.elegantthemes.com/blog/resources/bad-web-design-a-look-at-the-most-hilariously-terrible-websites-from-around-the-web
if __name__ == '__main__':
  if len(sys.argv) not in (1,2,3,4):
    print ('usage: download_pdf.py <html page> <timeout> <disable_everything>')
    ''' example:
     python disable_everything_chome.py "https://blinkee.com"
    '''
    exit()
  if len(sys.argv) > 1:
    url = sys.argv[1]
    match = re.match(r'^(https?://).*$', url, re.UNICODE)
    if match == None:
      url = 'https://{}'.format(url)
  else:
    url = None
  if len(sys.argv) >= 3:
    timeout = sys.argv[2]
  else:
    timeout = None
  if len(sys.argv) >= 4:
    disable_everything = sys.argv[3]
  else:
    disable_everything = None

  result = open_url( url, timeout, disable_everything )


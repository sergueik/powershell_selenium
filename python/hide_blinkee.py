#!/usr/bin/env python

# based on https://qna.habr.com/q/778499
# for testing of the effect of turning off dynamic elements like styles and scripts
# found the site that  becomes completey invisible when dynamic elements support is disabled
#
from __future__ import print_function
import sys
import re
import os
import time
from os import getenv, path
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.common.exceptions import ElementNotInteractableException
from selenium.common.exceptions import ElementClickInterceptedException

is_windows = getenv('OS') != None and re.compile('.*NT').match( getenv('OS'))
homedir = getenv('USERPROFILE' if is_windows else 'HOME')
default_downloads_dir = homedir + os.sep + 'Downloads'

def open_url(
  url = None,
  timeout = None,
  enable_dynamic = None,
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

  options.add_argument('--enable_dynamic-gpu')
  options.add_argument('--enable-javascript')
  options.add_argument('--enable_dynamic-dev-shm-usage')
  options.add_argument('--no-sandbox')
  options.add_argument('--ignore-certificate-errors')
  options.add_argument('--allow-insecure-localhost')
  options.add_argument('--allow-running-insecure-content')
  options.add_argument('--enable_dynamic-browser-side-navigation')
  if ( enable_dynamic is None ) or (    enable_dynamic.lower() in ['false', '0', 'no'] ) :
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
  except ElementNotInteractableException,e:
  # python 3 syntax
  # except ElementNotInteractableException as e:
    print('Exception, ignoring: {0}'.format(str(e)))
    print ('Element {} was not clickable'.format(data))

  except ElementClickInterceptedException,e :
  # python 3 syntax
  # except ElementClickInterceptedException as e:
    print('Exception, ignoring: {0}'.format(str(e)))
    print ('Element {} was not clickable, but visible'.format(data))

  time.sleep(float(timeout))
  driver.close()
  driver.quit()
		
# site picked from https://blog.rankingbyseo.com/bad-websites/ winner list
# and https://www.elegantthemes.com/blog/resources/bad-web-design-a-look-at-the-most-hilariously-terrible-websites-from-around-the-web
if __name__ == '__main__':
  if len(sys.argv) not in (1,2,3,4):
    print ('usage: download_pdf.py <html page> <timeout> <enable_dynamic>')
    ''' example:
      python enable_dynamic_chome.py "https://blinkee.com" 10 true
      # run it to see the site
      python enable_dynamic_chome.py "https://blinkee.com" 10 false
      # run it to see the site disappear

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
    enable_dynamic = sys.argv[3]
  else:
    enable_dynamic = None

  result = open_url( url, timeout, enable_dynamic )



#!/usr/bin/env python3

from __future__ import print_function
import os
import sys
import re
import time
from os import getenv
from selenium import webdriver
from selenium.common.exceptions import WebDriverException
from selenium.common.exceptions import InvalidSelectorException
from selenium.common.exceptions import NoSuchElementException

from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions
from selenium.webdriver.chrome.options import Options

is_windows = getenv('OS') != None and re.compile('.*NT').match( getenv('OS'))
homedir = getenv('USERPROFILE' if is_windows else 'HOME')

chromedriver_path = homedir + os.sep + 'Downloads' + os.sep + ('chromedriver.exe' if is_windows else 'chromedriver')
options = Options()
driver = webdriver.Chrome(executable_path = chromedriver_path, options = options)
if driver != None:
  driver.get('https://www.seleniumeasy.com/test/')

url = 'https://crossbrowsertesting.com/?utm_source=seleniumeasy&amp;utm_medium=da&amp;utm_campaign=sedemo'
url_fragment = 'https://crossBrowsertesting.com'
# https://stackoverflow.com/questions/24183701/xpath-lowercase-is-there-xpath-function-to-do-this
# https://developer.mozilla.org/en-US/docs/Web/XPath/Functions/translate
xpaths = [
  '//a[contains(@href,"{}")]'.format(url_fragment.lower()),
  '//a[contains(lower-case(@href),"{}")]'.format(url_fragment),
  '//a[contains(translate(@href, "b", "B"), "{}")]'.format(url_fragment),
  # NOTE: missing quotes is failing
  '//a[contains(translate(@href, ab, AB ), "{}")]'.format(url_fragment),
  '//a[contains(translate(@href, "ab", "AB" ), "{}")]'.format(url_fragment),
   '//a[contains(translate(@href, "abcdefghijklmnopqrstuvwxyz", "ABCDEFGHIJKLMNOPQRSTUVWXYZ"), "{}")]'.format(url_fragment.upper())
]
length = len(xpaths)
for cnt in range(length):
  xpath = xpaths[cnt]

  print('# try {}'.format(cnt))
  element = None
  try:
    element = driver.find_element_by_xpath(xpath)
  except InvalidSelectorException, e:
    print('Exception (ignored): {}'.format(e))
    pass
  except NoSuchElementException, e:
    print('Exception (ignored): {0}'.format(e))
    pass
  if element != None:
    print('Found via {}'.format(xpath))
    print(element.get_attribute('outerHTML'))
  else:
    print('Failed via {}'.format(xpath))

time.sleep(5)

driver.close()
driver.quit()


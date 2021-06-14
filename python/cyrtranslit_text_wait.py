#!/usr/bin/env python3

# based on the duscission:
# https://qna.habr.com/q/1003673?e=11379133#clarification_1256865

from cyrtranslit import to_latin

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.support import expected_conditions
from selenium.webdriver.chrome.options import Options as Options

import sys
import time
import datetime
import os

class waittest:
  def __init__(self, selector, value):
    self.selector = selector
    self.value = value
  def __call__(self, driver):
    element = driver.find_element_by_css_selector(self.selector)
    text = element.text
    print('checking text: "{}" against "{}"'.format(to_latin(text, 'ru'), self.value))
    if to_latin(text, 'ru') == self.value:
      return element
    else:
      return None
if os.getenv('OS') != None :
  homedir = os.getenv('USERPROFILE').replace('\\', '/')
  chromedriver = 'chromedriver.exe'
else:
  homedir = os.getenv('HOME')
  chromedriver = 'chromedriver'
url = 'https://www.discord.org.ru'
options = Options()
options.add_argument('--headless')
options.add_argument('--disable-gpu')
options.add_argument('--disable-dev-shm-usage')
options.add_argument('--no-sandbox');
options.add_argument('--disable-extensions')
driver = webdriver.Chrome(homedir + '/' + 'Downloads' + '/' + chromedriver, chrome_options = options)

driver.get(url)

element = WebDriverWait(driver, 10).until( waittest('a[class *= "fasc-button"]', to_latin('Cкачать Discord', 'ru')))
print( 'Found element "{}"'.format(element.get_attribute('outerHTML')))

driver.close()
driver.quit()


# export PATH=$PATH:$HOME/Downloads
# PATH=%PATH%;c:\Python381;c:\Python381\Scripts;%userprofile%\downloads

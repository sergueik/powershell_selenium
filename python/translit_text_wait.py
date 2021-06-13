#!/usr/bin/env python3
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

# https://pypi.org/project/cyrtranslit/#files
# https://stackoverflow.com/questions/47420957/create-custom-wait-until-condition-in-python
# https://selenium-python.readthedocs.io/waits.html
class translit_text_wait:
  # dictionary is to transliterate from Russian cyrillic to latin.

  RU_CYR_TO_LAT_DICT = { u"А": u"A", u"а": u"a",

      u"Б": u"B", u"б": u"b",
      u"В": u"V", u"в": u"v",
      u"Г": u"G", u"г": u"g",
      u"Д": u"D", u"д": u"d",
      u"Е": u"E", u"е": u"e",
      u"Ё": u"YO", u"ё": u"yo",
      u"Ж": u"ZH", u"ж": u"zh",
      u"З": u"Z", u"з": u"z",
      u"И": u"I", u"и": u"i",
      u"Й": u"J", u"й": u"j",
      u"К": u"K", u"к": u"k",
      u"Л": u"L", u"л": u"l",
      u"М": u"M", u"м": u"m",
      u"Н": u"N", u"н": u"n",
      u"О": u"O", u"о": u"o",
      u"П": u"P", u"п": u"p",
      u"Р": u"R", u"р": u"r",
      u"С": u"S", u"с": u"s",
      u"Т": u"T", u"т": u"t",
      u"У": u"U", u"у": u"u",
      u"Ф": u"F", u"ф": u"f",
      u"Х": u"H", u"х": u"h",
      u"Ц": u"C", u"ц": u"c",
      u"Ч": u"CH", u"ч": u"ch",
      u"Ш": u"SH", u"ш": u"sh",
      u"Щ": u"SZ", u"щ": u"sz",
      u"Ъ": u"#", u"ъ": u"#",
      u"Ы": u"Y", u"ы": u"y",
      u"Ь": u"'", u"ь": u"'",
      u"Э": u"EH", u"э": u"eh",
      u"Ю": u"JU", u"ю": u"ju",
      u"Я": u"JA", u"я": u"ja",
  }

  def encode_utf8(self , data):
    if sys.version_info < (3, 0):
      return data.encode('utf-8')
    else:
      return data
  def decode_utf8(self , data):
    if sys.version_info < (3, 0):
      return data.decode('utf-8')
    else:
      return data

  def to_latin(self, localized_string):
    # Initialize the output latin string variable
    latinized_str = ''
    localized_string = self.decode_utf8(localized_string)
    length_of_string = len(localized_string)
    index = 0
    for c in localized_string:
      if c in self.RU_CYR_TO_LAT_DICT:
        latinized_str += self.RU_CYR_TO_LAT_DICT[c]
      else:
        latinized_str += c
    index += 1
    return self.encode_utf8(latinized_str)

  def __init__(self, selector, value):
    self._selector = selector
    self._value = value

  def __call__(self, driver):
    element = driver.find_element_by_css_selector(self._selector)
    text = element.text
    print('checking text: "{}" against "{}"'.format(self.to_latin(text), self._value))
    if self.to_latin(text) == self._value:
      return element
    else:
      return None

if os.getenv('OS') != None :
  homedir = os.getenv('USERPROFILE').replace('\\', '/')
  chromedriver = 'chromedriver.exe'
else:
  homedir = os.getenv('HOME')
  chromedriver = 'chromedriver'
url = 'http://ya.ru/'
options = Options()
# options.add_argument('--headless')
# options.add_argument('--disable-gpu')
# export PATH=$PATH:$HOME/Downloads
# DevToolsActivePort file doesn't exist
driver = webdriver.Chrome(homedir + '/' + 'Downloads' + '/' + chromedriver, options = options)
driver = webdriver.Chrome()

driver.get(url)
element = WebDriverWait(driver, 10).until( translit_text_wait("button[class *= 'button']", 'Najti') )
print( 'Found element "{}"'.format(element.get_attribute('innerHTML')))

driver.close()
driver.quit()

#  PATH=%PATH%;c:\Python381;c:\Python381\Scripts;%userprofile%\downloads

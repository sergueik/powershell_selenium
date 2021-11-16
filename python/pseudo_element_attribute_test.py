#!/usr/bin/env python3

# https://stackoverflow.com/questions/5041494/selecting-and-manipulating-css-pseudo-elements-such-as-before-and-after-usin

from __future__ import print_function
import sys
import re
import time
from os import getenv, path
from selenium import webdriver
from selenium.webdriver.chrome.options import Options

if __name__ == '__main__':
  default_downloads_dir = getenv('USERPROFILE' if getenv('OS') == 'Windows_NT' else 'HOME') + '/' + 'Downloads'
  chromedriver_path = default_downloads_dir + '/' + ('chromedriver.exe' if getenv('OS') ==  'Windows_NT' else 'chromedriver')
  options = Options()
  default_downloads_dir = getenv('USERPROFILE' if getenv('OS') == 'Windows_NT' else 'HOME') + '/' + 'Downloads'
  chromedriver_path = default_downloads_dir + '/' + ('chromedriver.exe' if getenv('OS') ==  'Windows_NT' else 'chromedriver')
  driver = webdriver.Chrome(chromedriver_path, options = options)
  filename = 'trycss_before'
  url = 'https://www.w3schools.com/css/tryit.asp?filename={}'.format(filename)
  driver.get(url)
  frame_css = 'div#iframewrapper iframe[name="iframeResult"]'
  frame_element = driver.find_element_by_css_selector(frame_css)
  print(frame_element.get_attribute('outerHTML'))
  driver.switch_to.frame(frame_element)
  element_xpath = '//h1'
  element = driver.find_element_by_xpath(element_xpath)
  print( element.get_attribute('innerHTML'))
  driver.implicitly_wait(10)
  script = 'return window.getComputedStyle(arguments[0],":before")'
  data = driver.execute_script(script, element)
  print('Result(raw) : {}'.format(data))
  for data_key in data:
    print('element: {}'.format(data_key))
  script = 'return window.getComputedStyle(arguments[0],":before").getPropertyValue(arguments[1]);'
  for property_key in ['top', 'left', 'width', 'height', 'content']:
    property_value = driver.execute_script(script, element, property_key)
    print('element property {} = {}'.format(property_key, property_value))
  driver.switch_to.default_content()
  driver.close()
  driver.quit()

#  PATH=%PATH%;c:\Python381;c:\Python381\Scripts;%userprofile%\downloads

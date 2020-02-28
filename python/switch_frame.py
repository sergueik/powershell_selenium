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

if __name__ == '__main__':
  default_downloads_dir = getenv('USERPROFILE' if getenv('OS') == 'NT' else 'HOME') + '/' + 'Downloads'
  chromedriver_path = default_downloads_dir + '/' + ('chromedriver.exe' if getenv('OS') == 'NT' else 'chromedriver')
  options = Options()
  driver = webdriver.Chrome(chromedriver_path, chrome_options = options)
  url = 'https://www.w3schools.com/css/tryit.asp?filename=trycss_before'
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

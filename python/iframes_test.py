#!/usr/bin/env python3

# see also:
# https://www.tutorialspoint.com/how-to-handle-frames-in-selenium-with-python

from __future__ import print_function
import sys
import re
import time
from os import getenv, path
from selenium import webdriver
from selenium.common import exceptions
from selenium.webdriver.chrome.options import Options

if __name__ == '__main__':
  default_downloads_dir = getenv('USERPROFILE' if getenv('OS') == 'Windows_NT' else 'HOME') + '/' + 'Downloads'
  chromedriver_path = default_downloads_dir + '/' + ('chromedriver.exe' if getenv('OS') ==  'Windows_NT' else 'chromedriver')
  options = Options()
  options.add_argument('--disable-gpu')
  options.add_argument('--headless')
  # Windows 7 VM is at 100% CPU when chrome is visible
  driver = webdriver.Chrome(chromedriver_path, options = options)
  filename = 'tryhtml_iframe'
  url = 'https://www.w3schools.com/tags/tryit.asp?filename={}'.format(filename)
  driver.get(url)
  frame_css = 'iframe[name="iframeResult"]'
  frame_element = driver.find_element_by_css_selector(frame_css)
  print('frame1: {}'.format( frame_element.get_attribute('outerHTML')))
  driver.switch_to.frame(frame_element)
  text = 'The iframe element'
  element_xpath = '//h1[contains(normalize-space(.),"{}")]'.format(text)
  element = driver.find_element_by_xpath(element_xpath)
  print('element found in iframe1: {}'.format(element.get_attribute('innerHTML')))
  driver.implicitly_wait(1)
  title = 'W3Schools Free Online Web Tutorials'
  frame_element = driver.find_element_by_xpath('//iframe[@title = "{}"]'.format(title))
  print('frame2: {}'.format( frame_element.get_attribute('outerHTML')))
  driver.switch_to.frame(frame_element)
  href = "/html/default.asp"
  element = driver.find_element_by_css_selector('.w3-button[href = "{}"]'.format(href))
  print('element found in iframe2: {}'.format(element.get_attribute('innerHTML')))
  try:
    element.click()
  except exceptions.ElementNotInteractableException as e:
    print(e)
    pass

  # selenium.common.exceptions.ElementNotInteractableException: Message: element not interactable 
  driver.switch_to.default_content()
  driver.close()
  driver.quit()

#  PATH=%PATH%;c:\Python381;c:\Python381\Scripts;%userprofile%\downloads
 

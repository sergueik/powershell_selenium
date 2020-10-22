#!/usr/bin/env python
from __future__ import print_function

import sys
import re
from os import getenv,environ
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import NoAlertPresentException
from selenium.common.exceptions import TimeoutException
import time
import datetime

class title_matches(object):
  def __init__(self, title_fragment):
    self.title_fragment = title_fragment

  def __call__(self, driver):
    title = driver.title
    if re.match('.*' + self.title_fragment + '.*', title, re.IGNORECASE):
      return title
    else:
      return False

def main():
  if getenv('OS') != None :
    homedir = getenv('USERPROFILE').replace('\\', '/')
    chromedriver = 'chromedriver.exe'
  else:
    homedir = getenv('HOME')
    chromedriver = 'chromedriver'
  url = 'https://mail.google.com/'
  # title = 'YouTube'
  options = Options()
  # https://stackoverflow.com/questions/56637973/how-to-fix-selenium-devtoolsactiveport-file-doesnt-exist-exception-in-python
  # https://software-testing.ru/forum/index.php?/topic/39617-ne-nakhodit-element-pri-ispolzovanii-optcii-headless/
  if len(sys.argv) == 2:
    if sys.argv[1] == 'headless':
      # Does one still needs X
      options.add_argument('--headless')
      options.add_argument('--disable-gpu')
      options.add_argument('--remote-debugging-port=9222')
      # the below flags are critical to get the DOM similar
      # to that of visual browser page
      options.add_argument('--enable-javascript')
      # probably this one
      options.add_argument("--user-agent='Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:72.0) Gecko/20100101 Firefox/72.0'")
      options.add_argument('--no-sandbox')
      options.add_argument('--ignore-certificate-errors')
      options.add_argument('--allow-insecure-localhost')

  environ['PATH'] = environ['PATH'] + ':' + homedir + '/' + 'Downloads'

  driver = webdriver.Chrome(homedir + '/' + 'Downloads' + '/' + chromedriver, options = options)
  driver.get(url)

  wait = WebDriverWait(driver, 10)
  # title_fragment = 'Gmail - Email from Google'
  title_fragment = 'Gmail.*'
  title = wait.until(title_matches(title_fragment))
  try:
    # https://selenium-python.readthedocs.io/waits.html
    WebDriverWait(driver,10).until(EC.title_contains(title))
    print('Page title is: "{}"'.format(driver.title), file = sys.stderr)
  except (TimeoutException) as e:
    print('Unexected exception waiting for Page title change: {0}'.format(e))
  # visible
  selector = 'div input[type="email"][ autocomplete= "username"]'
  # backing(also failing - found through printing page source)
  # selector = 'input#Email"[type="email"]'
  try:
    element = WebDriverWait(driver, 10).until(EC.visibility_of_element_located((By.CSS_SELECTOR, selector)))
    if element != None:
      print('Found input element: {}'.format(element.get_attribute('outerHTML')))
      element.clear()
      element.send_keys('test@gmail.com')
  except (Exception) as e:
    print('Page was not shown or rendered properly. Exception: {0}'.format(e))
    driver.save_screenshot("screenshot.png")
    print("Page source:\n{}",format(driver.page_source))
  finally:
    driver.quit()

if __name__ == '__main__':
  main()

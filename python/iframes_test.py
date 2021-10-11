#!/usr/bin/env python

# origin: https://www.techbeamers.com/switch-between-iframes-selenium-python/
# NOTE:  www.google.com seems to refuse to connect when in iframe
import sys, pprint, zipfile,os,time
from os import getenv,path
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import NoAlertPresentException,TimeoutException,WebDriverException
from selenium.webdriver.chrome.options import Options as Options

if os.getenv('OS') != None :
  homedir = os.getenv('USERPROFILE').replace('\\', '/')
  chromedriver = 'chromedriver.exe'
else:
  homedir = os.getenv('HOME')
  chromedriver = 'chromedriver'
options = Options()
# options.add_argument('--headless')
# options.add_argument('--disable-gpu')

driver = webdriver.Chrome(homedir + '/' + 'Downloads' + '/' + chromedriver, options = options)
url = 'file:///{0}/{1}'.format(os.getcwd(), 'iframes_test.html')

driver.get(url)

seq = driver.find_elements_by_tag_name('iframe')

print('# of frames present in the web page is: {}'.format(len(seq)))

for index in range(len(seq)):
  # try 
  # driver.switch_to.frame(seq[index])
  # stale element
  print('Switched to default content {}'.format(driver.page_source[0:100]))
  driver.switch_to.default_content()
  print('Switch to frame: {}'.format(index))
  iframe = driver.find_elements_by_tag_name('iframe')[index]
  driver.switch_to.frame(iframe)
  driver.implicitly_wait(30)
  print('the url is {}'.format(driver.page_source[0:100]))

  # element = driver.find_element_by_css_selector('#searchInput')
  element =   driver.find_element_by_xpath('//input[contains("search text", @type)]')
  print('found element: {}'.format(element.get_attribute('outerHTML')))
  element.send_keys(Keys.CONTROL, 'a')
  time.sleep(2)
  # https://stackoverflow.com/questions/61192271/python-selenium-switch-to-default-content-not-working
driver.switch_to.default_content()
driver.close()
driver.quit()


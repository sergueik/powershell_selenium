#!/usr/bin/env python3

# origin: https://www.cyberforum.ru/python-web/thread2865304.html

from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.firefox.options import Options

import sys, time, datetime
import getopt
from os import getenv

# TODO: explore
# from webdriver_manager.firefox import GeckoDriverManager
if getenv('OS') != None :
  homedir = getenv('USERPROFILE').replace('\\', '/')
  geckodriver = 'geckodriver.exe'
else:
  homedir = getenv('HOME')
  geckodriver = 'geckodriver'

options = Options()
options.add_argument('--no-sandbox')
options.add_argument('--disable-setuid-sandbox')
options.add_argument('--headless')

# aternatively:
options.headless = True

url = 'https://qna.habr.com'
binary = '{}/Downloads/firefox/firefox'.format(homedir)
driver = '{}/Downloads/{}'.format(homedir, geckodriver)
# TODO: explore
# it is known to lead to the following failure:
# Selenium.common.exceptions.TimeoutException: Message: Connection refused (os error 111)
# when driver instance is using constructor signature
# executable_path=GeckoDriverManager().install()
# webdriver.Firefox( firefox_options = options, executable_path = executable_path)


# print ('starting: webdriver.firefox({},{},{})'.format(binary, driver, options))
driver = webdriver.Firefox(firefox_binary = binary, executable_path = driver, firefox_options = options )
try:
  driver.get(url = url)
  time.sleep(1)
  print('navigated to {}'.format(driver.current_url))
 
except Exception as e:
  print(e)
 
finally:
  driver.close()
  driver.quit()


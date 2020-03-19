#!/usr/bin/env python3

# https://qna.habr.com/q/734219

from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.support import expected_conditions
from selenium.webdriver.common.by import By
from os import getenv
import time
import sys

url = 'https://www.yahoo.com'
if getenv('OS') != None :
  homedir = getenv('USERPROFILE').replace('\\', '/')
else:
  homedir = getenv('HOME')

options = Options()
driver = webdriver.Chrome( executable_path = homedir + '/' + 'Downloads' + '/' + 'chromedriver', options = options)
driver.implicitly_wait(10)
driver.get(url)
WebDriverWait(driver, 120).until( expected_conditions.presence_of_element_located((By.ID,'header-search-input')))
driver.find_element_by_id('header-search-input').send_keys('test test test test')
time.sleep(1)
driver.find_element_by_id('header-search-input').send_keys(Keys.CONTROL + 'a')
time.sleep(1)
driver.find_element_by_id('header-search-input').send_keys/'other text')
time.sleep(120)

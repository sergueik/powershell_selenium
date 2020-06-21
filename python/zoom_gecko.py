#!/usr/bin/env python

from selenium import webdriver
from selenium.webdriver.firefox.options import Options
from selenium.webdriver.firefox.firefox_binary import FirefoxBinary
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.actions.interaction import KEY
from selenium.webdriver.common import keys

import time, datetime, os
from os import getenv

if __name__ == "__main__":
  # now Firefox will run in a virtual display.
  options = Options()
  # options.headless = True
  binary = FirefoxBinary('/usr/bin/firefox')

  driver = webdriver.Firefox(firefox_binary = binary, executable_path = '{}/Downloads/geckodriver'.format(getenv('HOME')), options = options)

  # Sets the width and height of the current window
  driver.set_window_size(1366, 768)

  # Open the URL
  driver.get('http://www.wikipedia.org/')

  # set timeouts
  driver.set_script_timeout(30)
  driver.set_page_load_timeout(30) # seconds

  search_bar = driver.find_element_by_css_selector('body')
  #Create the object for Action Chains
  actions = ActionChains(driver)
  print('test 1')
  actions.key_down(keys.Keys.CONTROL)
  actions.send_keys('0')
  actions.key_up(keys.Keys.CONTROL)
  actions.perform()
  time.sleep(10)
  print('test 2')
  zoom = 50
  # https://stackoverflow.com/questions/28111539/can-we-zoom-the-browser-window-in-python-selenium-webdriver
  driver.execute_script("document.body.style.zoom='{} %'".format(zoom))
  time.sleep(10)
  print('test 3')
  driver.execute_script("document.body.style.transform = 'scale(0.8)'")
  time.sleep(10)
  print('test 4')
  driver.execute_script('document.body.style.MozTransform = "scale(0.50)";')
  time.sleep(10)
  # quit driver
  driver.quit()

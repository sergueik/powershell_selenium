#!/usr/bin/env python3

from selenium import webdriver
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
from selenium.webdriver.firefox.options import Options
# see also: https://www.programcreek.com/python/example/100023/selenium.webdriver.Remote

hub = 'http://{}:4444/wd/hub'.format(host)
# for browserstack instance
# 'http://{}:{}@hub-cloud.browserstack.com/wd/hub'.format(user,password)
# for saucelab
# 'http://{}:{}@ondemand.saucelabs.com:80/wd/hub'.format(user,password)
def get_driver(browser):
  
  if browser.lower() == 'ff' or browser.lower() == 'firefox'
    options = webdriver.FirefoxOptions()
    options.add_argument('headless')  
    # driver = webdriver.Remote(command_executor = hub, desired_capabilities = DesiredCapabilities.FIREFOX)
    # driver = webdriver.Remote(command_executor = hub, desired_capabilities = optons.to_capabilities())
  else
    options = webdriver.ChromeOptions()
    options.add_argument("no-sandbox")
    options.add_argument("--disable-gpu")
    options.add_argument("--window-size=800,600")
    options.add_argument("--disable-dev-shm-usage")
    options.set_headless()
    driver = webdriver.Remote( command_executor = hub, desired_capabilities = DesiredCapabilities.CHROME, options=options,)
  
  return driver

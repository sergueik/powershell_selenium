from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
# https://github.com/SergeyPirogov/webdriver_manager
from selenium.webdriver.chrome.service import Service as ChromeService
from webdriver_manager.chrome import ChromeDriverManager
from webdriver_manager.core.utils import ChromeType
# from bs4 import BeautifulSoup as bs
from subprocess import run


import time
import getopt
import re
import sys
from os import getenv

def get_source_html(url):
  if getenv('OS') != None:
    running_on_windows = True
  else:
    running_on_windows = False
  if running_on_windows:
    homedir = getenv('USERPROFILE').replace('\\', '/')
  else:
    homedir = getenv('HOME')

  options = Options()
  # Without ChromeDriverManager:
  # driver = webdriver.Chrome( homedir + '/' + 'Downloads' + '/' + 'chromedriver', options = options)

  # NOTE: webdriver-manager-3.8.3 handles selenium-4.x.x
  # but needs python 3.7  or later
  # for bionic 18.04 use https://linuxize.com/post/how-to-install-python-3-7-on-ubuntu-18-04/
  # and then manually update /usr/bin/pip3
  # TODO: detect Selenium 3.x verus 4.x - syntax is version sensitive
  # driver = webdriver.Chrome(Service(ChromeDriverManager().install()))
  # TypeError: expected str, bytes or os.PathLike object, not Service
  if running_on_windows:
    chrome_type = ChromeType.GOOGLE
  else:
    p = run( [ 'which', 'chromium-browser' ] )
    if p.returncode == 0:
      chrome_type = ChromeType.CHROMIUM
    else:
      chrome_type = ChromeType.GOOGLE

  driver = webdriver.Chrome(ChromeDriverManager(chrome_type = chrome_type).install())
  # the cached drivers saved under ~/.wdm/drivers/chromedriver/linux64/$VERSION/chromedriver
  # NOTE: WebDriver manager fails to discover chromium-browser, probably does not try
  # [WDM] - Could not get version for google-chrome. Is google-chrome installed?

  # driver.maximize_window()

  try:
    driver.get(url = url)
    time.sleep(1)
  except Exception as e:
    print(e)
  finally:
    driver.close()
    driver.quit()

def main():
  get_source_html(url = 'https://google.com')

if __name__ == '__main__':
  main()


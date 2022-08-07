from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
# https://github.com/SergeyPirogov/webdriver_manager
from selenium.webdriver.chrome.service import Service as ChromeService
from webdriver_manager.chrome import ChromeDriverManager
# from bs4 import BeautifulSoup as bs
import time
import getopt
import re
import sys
from os import getenv

def get_source_html(url):
  if getenv('OS') != None :
    homedir = getenv('USERPROFILE').replace('\\', '/')
  else:
    homedir = getenv('HOME')

  options = Options()
  # Without ChromeDriverManager:
  # driver = webdriver.Chrome( homedir + '/' + 'Downloads' + '/' + 'chromedriver', options = options)


  # TODO: detect Selenium 3.x verus 4.x - syntax is version sensitive
  # driver = webdriver.Chrome(Service(ChromeDriverManager().install()))
  # TypeError: expected str, bytes or os.PathLike object, not Service
  driver = webdriver.Chrome(ChromeDriverManager().install())
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


import sys
import re
from os import getenv
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import NoAlertPresentException
from selenium.common.exceptions import TimeoutException

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
  url = 'https://www.youtube.com/'
  # title = 'YouTube'
  options = Options()
  # options.add_argument('--headless')
  # options.add_argument('--disable-gpu')

  driver = webdriver.Chrome(homedir + '/' + 'Downloads' + '/' + chromedriver, options = options)
  driver = webdriver.Chrome()
  driver.get(url)

  wait = WebDriverWait(driver, 10)
  title_fragment = 'Youtube'
  title = wait.until(title_matches(title_fragment))
  try:
    # https://selenium-python.readthedocs.io/waits.html
    WebDriverWait(driver,10).until(EC.title_contains(title))
    print('page title is {}'.format(driver.title), file = sys.stderr)

  except (TimeoutException) as e:
    print('page was not shown: {0}'.format(e))
  finally:
    driver.quit()

if __name__ == '__main__':
  main()

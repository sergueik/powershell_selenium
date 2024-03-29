#!/usr/bin/env python3
# has both FF and Chrome initialization code
# origin: https://groups.google.com/forum/#!topic/selenium-users/PuDpVblziAo

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.support.ui import Select
from selenium.common.exceptions import NoSuchElementException

# Ability to run headless
from selenium.webdriver.firefox.options import Options as firefox_options
from selenium.webdriver.chrome.options import Options as chrome_options
from selenium.webdriver.firefox.firefox_binary import FirefoxBinary

# package to allow one to download the page
# sudo -H pip3 install parsel --upgrade	
# on Windows, do
# PATH=%PATH%;c:\Python381;c:\Python381\Scripts;%userprofile%\downloads
# python -m pip install parsel
from parsel import Selector

import sys, time, datetime, os
import getopt
from os import getenv


class headlessbypass:

  my_date_time = datetime.datetime.now().strftime('%Y%m%d%H%M%S')

  def firefox_headless_func(self):
    self.options = firefox_options()
    self.options.headless = True
    # system wide

    binary = FirefoxBinary('/usr/bin/firefox')
    binary = '{}/Downloads/firefox/firefox'.format(self.homedir)
    # TODO: handle Windows
    # FirefoxBinary('c:/Users/{}/AppData/Local/Mozilla Firefox/firefox.exe'.formatt(getenv('USERNAME'))
    self.driver = webdriver.Firefox(firefox_binary = binary, executable_path = '{}/Downloads/{}'.format(self.homedir,self.geckodriver), options = self.options)

  def chrome_headless_func(self):
    self.options = chrome_options()
    #self.options.headless = True
    self.options.add_argument('--window-size=1920, 1080')
    #self.options.add_argument('--disable-extensions')
    #self.options.add_argument('--proxy-server='direct://'')
    #self.options.add_argument('--proxy-bypass-list=*')
    #self.options.add_argument('--start-maximized')
    self.options.add_argument('--headless')
    self.options.add_argument('--disable-gpu')
    #self.options.add_argument('--disable-dev-shm-usage')
    #self.options.add_argument('--no-sandbox')
    #self.options.add_argument('--ignore-certificate-errors')
    #self.options.add_argument("--allow-insecure-localhost")
    #self.options.add_argument("--allow-running-insecure-content")
    #self.options.add_argument('--disable-browser-side-navigation')
    self.options.add_argument('--enable-javascript')
    self.options.add_argument('--user-agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:72.0) Gecko/20100101 Firefox/72.0"')
    # self.options.add_argument("user-agent=Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.107 Safari/537.36")
    # Cope with 64/32. Assume 32 bit Chrome is installed
    self.options.binary_location = '/usr/bin/google-chrome' if getenv('OS') == None else 'C:/Program Files (x86)/Google/Chrome/Application/chrome.exe' if getenv('ProgramW6432') != None else 'C:/Program Files/Google/Chrome/Application/chrome.exe'
    # additional options
    self.options.add_experimental_option('excludeSwitches', ['enable-automation'])
    self.options.add_argument('--incognito')
    prefs = {'safebrowsing.enabled': True, 'gcredentials_enable_service': False,'gprofile.password_manager_enabled' : False,'gcredentials_enable_service': False,'gprofile.password_manager_enabled': False }
    self.options.add_experimental_option('prefs', prefs)
    self.options.add_argument('--disable-blink-features=AutomationControlled')
    self.options.add_argument('--disable-infobars')
    self.options.add_argument('--safebrowsing-disable-extension-blacklist')
    self.options.add_argument('--safebrowsing-disable-download-protection')
    self.driver = webdriver.Chrome(options = self.options,executable_path = '{}/Downloads/{}'.format(self.homedir,self.chromedriver))

  def my_set_up(self):
    if os.getenv('OS') != None :
      self.homedir = os.getenv('USERPROFILE').replace('\\', '/')
      self.chromedriver = 'chromedriver.exe'
      self.geckodriver = 'geckodriver.exe'
    else:
      self.homedir = os.getenv('HOME')
      self.chromedriver = 'chromedriver'
      self.geckodriver = 'geckodriver'
    print('browser = {} , headless = {}'.format(browser,headless))
    if headless:
      if browser == 'firefox':
        self.firefox_headless_func()
      elif browser == 'chrome':
        self.chrome_headless_func()
    else:
      if browser == 'chrome':
        self.driver = webdriver.Chrome(executable_path = '{}/Downloads/{}'.format(self.homedir,self.chromedriver))
      else:
        print('{}/Downloads/{}'.format(self.homedir,self.geckodriver))
        self.driver = webdriver.Firefox(executable_path = '{}/Downloads/{}'.format(self.homedir,self.geckodriver))

    self.driver.implicitly_wait(30)
    self.driver.maximize_window()

    main_window = self.driver.current_window_handle
    self.driver.switch_to.window(main_window)

  def my_tear_down(self):
    self.driver.quit()

  # TODO: https://www.geeksforgeeks.org/decorators-with-parameters-in-python/
  def my_decorator(func):
    def wrapper(self, *args, **kwargs):
        self.my_set_up()
        func(self, *args, **kwargs)
        self.my_tear_down()
    return wrapper

  @my_decorator
  def visit_site(self):
    self.driver.get('https://mygocompare.gocompare.com/newcustomer/')

    time.sleep(2)
    print(self.driver.page_source)

    # Enter registration number

    reg_field = self.driver.find_element(By.XPATH, '//fieldset[1]/div[2]/div[2]/div/input')
    reg_field.send_keys("AK47")
    time.sleep(5)
    print("Take screenshot")
    html = self.driver.find_element_by_tag_name('html')
    html.send_keys(Keys.PAGE_UP)
    self.driver.save_screenshot("firstpagescreenshot.png")
    self.driver.find_element(By.XPATH, "//span[contains(text(), 'Find car')]").click()
    time.sleep(2)

    print("Take screenshot")
    html = self.driver.find_element_by_tag_name('html')
    html.send_keys(Keys.PAGE_UP)
    self.driver.save_screenshot('firstpagescreenshot2.png')

if __name__ == '__main__':
  try:
    opts, args = getopt.getopt(sys.argv[1:], 'hdb:u:n', ['help', 'debug', 'browser=', 'url=', 'nowindow'])
  except getopt.GetoptError as err:
    print('usage: print_pdf.py --url <html page> --browser <browser> [--headless]')
    print(str(err))
    exit()
  url = 'https://mygocompare.gocompare.com/newcustomer/'
  global browser
  browser = 'firefox'
  global headless
  # headless = os.getenv('HEADLESS_MODE')
  headless = False
  global debug
  debug = False
  for option, argument in opts:
    if option == '-d':
      debug = True
    elif option in ('-h', '--help'):
      print('usage: scraper_ex.py--url <html page> --browser <browser> [--headless]')
      exit()
    elif option in ('-u', '--url'):
      url = argument
    elif option in ('-b', '--browser'):
      browser = argument
    elif option in ('-n', '--nowindow'):
      headless = True
    else:
      assert False, 'unhandled option: {}'.format(option)
  start_time = time.time()
  scrape = headlessbypass()
  scrape.visit_site()

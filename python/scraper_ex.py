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
from selenium.webdriver.firefox.options import Options as f_Options
from selenium.webdriver.chrome.options import Options as c_Options
from selenium.webdriver.firefox.firefox_binary import FirefoxBinary

# package to allow one to download the page
# sudo -H pip3 install parsel --upgrade	
from parsel import Selector

import time, datetime, os
from os import getenv


class headlessbypass:

  my_date_time = datetime.datetime.now().strftime('%Y%m%d%H%M%S')

  def firefox_headless_func(self):
    self.options = f_Options()
    self.options.headless = True
    # system wide

    binary = FirefoxBinary('/usr/bin/firefox')
    binary = '{}/Downloads/firefox/firefox'.format(self.homedir)
    # TODO: handle Windows
    # FirefoxBinary('c:/Users/{}/AppData/Local/Mozilla Firefox/firefox.exe'.formatt(getenv('USERNAME'))
    self.driver = webdriver.Firefox(firefox_binary = binary, executable_path = '{}/Downloads/{}'.format(self.homedir,self.geckodriver), options = self.options)

  def chrome_headless_func(self):
    self.options = c_Options()
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
    self.options.binary_location = '/usr/bin/google-chrome'  # "C:/Program Files (x86)/Google/Chrome/Application/chrome.exe"
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
    headless = os.getenv('HEADLESS_MODE')
    # This is for running locally; select/toggle what you want to run
    headless_firefox = 1
    headless_chrome = 0
    chrome = 0
    safari = 0

    if headless:
      self.firefox_headless_func()
    else:
      if headless_firefox:
        self.firefox_headless_func()

      elif headless_chrome:
        self.chrome_headless_func()

      elif chrome:
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
  start_time = time.time()
  scrape = headlessbypass()
  scrape.visit_site()



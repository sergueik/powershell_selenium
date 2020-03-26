#!/usr/bin/env python3

from __future__ import print_function
import sys
import time
from os import getenv
from selenium import webdriver
from selenium.webdriver.chrome.options import Options

homedir = getenv('USERPROFILE' if getenv('OS') == 'NT' else 'HOME')

chromedriver_path = homedir + '/' + 'Downloads' + '/' + ('chromedriver.exe' if getenv('OS') == 'NT' else 'chromedriver')
options = Options()
print('chromedriver path: {}'.format(chromedriver_path))
dir_name = sys.argv[1]
if dir_name == None:
  dir_name = 'chromium.SAVED'
user_data_dir ='{0}\\AppData\\Local\\Google\\Chrome\\User Data\\{0}'.format(getenv('USERPROFILE'), dirname) if getenv('OS') == 'NT' else '/home/{}/.config/{}'.format(getenv('USER'), dir_name)
print('user data dir path: {}'.format(user_data_dir))
options.add_argument( 'user-data-dir={}'.format(user_data_dir))
driver = webdriver.Chrome(executable_path = chromedriver_path, options = options)
driver.get('chrome://version/')
time.sleep(10)
driver.close()
driver.quit()

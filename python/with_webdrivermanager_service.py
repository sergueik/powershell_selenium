#!/usr/bin/env python3
from __future__ import print_function

import os,sys,time,re
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.chrome.options import Options

def get_chromedriver():
  is_windows = os.getenv('OS') != None and re.compile('.*NT').match( os.getenv('OS'))

  profile_dir_name = None
  if len(sys.argv) > 1:
    profile_dir_name = sys.argv[1]
  if profile_dir_name == None:
    profile_dir_name = 'CustomProfile'
  user_data_dir = '{0}\\AppData\\Local\\Google\\Chrome\\User Data'.format(os.getenv('USERPROFILE'), profile_dir_name) if is_windows else '{0}/.config'.format(os.getenv('HOME'), profile_dir_name)
  # NOTE: using the user_data_dirabove leads to exception
  # selenium.common.exceptions.WebDriverException: Message: unknown error: Chrome failed to start: exited normally.
  user_data_dir = '{0}\\AppData\\Local\\Google\\Chrome\\User Data\\{1}'.format(os.getenv('USERPROFILE'), profile_dir_name) if is_windows else '{0}/.config/{1}'.format(os.getenv('HOME'), profile_dir_name)
  # NOTE: the actual profile dir will be created as 
  # '{os.getenv('HOME')}\\AppData\\Local\\Google\\Chrome\\User Data\\{profile_dir_name}\\{profile_dir_name}'
  # with profile_dir_name twice

  if os.path.isdir(user_data_dir):
    print('Custom profile will be used: "{}"'.format(user_data_dir), file = sys.stderr)
  else:
    print('Custom profile will be created: "{}"'.format(user_data_dir), file = sys.stderr)

  options = webdriver.ChromeOptions()
  options.add_argument('--profile-directory={}'.format(profile_dir_name))
  options.add_argument('user-data-dir={}'.format(user_data_dir))
  options.add_argument('--disable-blink-features=AutomationControlled')
  homedir = os.getenv('USERPROFILE' if is_windows else 'HOME')
  chromedriver_path = homedir + os.sep + 'Downloads' + os.sep + ('chromedriver.exe' if is_windows else 'chromedriver')
  service = Service(executable_path = chromedriver_path )
  driver = webdriver.Chrome( service = service, options = options )
  # Ubuntu 18.04 webdriver-manager 3.7.1:
  # got an unexpected keyword argument 'service'
  return driver


def main():
  driver = get_chromedriver()
  driver.get('https://vk.com')
  time.sleep(10)
  driver.close()
  driver.quit()

if __name__ =='__main__':
  main()

# pip install packaging==21.3
# pip install webdriver-manager==3.8.4
# pip install selenium==4.5.0
# on Ubuntu Linux, use pop3 instead of pip command and use 3.7.1 version for webdriver-manager (python version dependent)
# seeing Could not find a version that satisfies the requirement webdriver-manager==3.8.4 (from versions: ...
# ImportError: No module named webdriver_manager.chrome
# pip3 install selenium==4.0.0a7
# failing in compile

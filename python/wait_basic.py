#!/usr/bin/env python

# origin: https://www.techbeamers.com/selenium-webdriver-waits-python/
# see also: https://selenium-python.readthedocs.io/waits.html
import sys
import pprint
import zipfile
import os
from os import getenv,path
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common import exceptions

def create_firefox_extension(profile_path):
  # NOTE: __file__ requires running script as executable or 
  # provide current direcrory in the path to the script in python command like
  # python ./wait_basic1.py
  extension_path = path.abspath(
    #  path.dirname(__file__)
    os.getcwd() + path.sep + 'firefox_extension')
  print('Loading extensions from {}'.format(extension_path))
  extension_zip_file = profile_path + path.sep + 'extension.xpi'

  with zipfile.ZipFile(extension_zip_file, 'w', zipfile.ZIP_DEFLATED, False) as extension_zip:
    for file in ['manifest.json', 'content.js', 'arrive.js']:
      extension_zip.write(extension_path + path.sep + file, file)
  return extension_zip_file

def get_profile_path(profile):
  if getenv('OS') != None :
    homedir = getenv('USERPROFILE').replace('\\', '/')
    appata_path = path.join(getenv['APPDATA'],'Mozilla', 'Firefox', 'Profiles')
    profile_path = appdata_path
  else:
    homedir = getenv('HOME')
    config_path = path.join(homedir,'.mozilla','firefox')
    profile_path = config_path
  try:
    profiles = os.listdir(profile_path)
  except WindowsError:
    print("Could not find profiles directory in {}".format(profile_path))
    sys.exit(1)
  try:
    for folder in profiles:
      if folder.endswith(profile):
        # print(folder)
        profile_folder = folder
  except StopIteration:
    print('Firefox profile not found in {}'.format(profile_path))
    sys.exit(1)
  # NOTE: redefining
  profile_path = path.join(profile_path, profile_folder)
  print('profile path: {}'.format(profile_path))
  return profile_path

if __name__ == '__main__':
  profile_path = get_profile_path('default')
  profile = webdriver.FirefoxProfile(profile_path)
  # pprint(profile)
  # TypeError: 'module' object is not callable

  # driver = webdriver.Firefox(firefox_profile = profile_path)
  driver = webdriver.Firefox()
  # add extenions to hide selenium
  driver.install_addon(create_firefox_extension(profile_path), temporary=True)
  driver.maximize_window()
  location = 'file:///{0}/{1}'.format(os.getcwd(), 'alert.html')
  try:
    driver.get(location)
  except exceptions.WebDriverException as e:
    # Reached error page: about:neterror?e=fileNotFound&u=file%3A////home/sergueik/Downloads/alert.html&c=UTF-8&d=Firefox%20can%E2%80%99t%20find%20the%20file%20at%20//home/sergueik/Downloads/alert.html
    print('Exception (ignored): {}'.format(str(e)))
    driver.quit()
    exit

  button = driver.find_element_by_name('alert')
  button.click()

  try:
    WebDriverWait(driver,10).until(EC.alert_is_present())
    alert = driver.switch_to.alert
    msg = alert.text
    print ('Alert message: {}'.format(msg) )
    alert.accept()

  except (exceptions.NoAlertPresentException, exceptions.TimeoutException) as e:
    print('Alert was not shown: {0}'.format(e))
    print (e.args)
  except: # catch *all* exceptions
    e = sys.exc_info()[0]
    print('Exception (ignored): {}'.format(str(e)))
    pass
  finally:
    driver.quit()


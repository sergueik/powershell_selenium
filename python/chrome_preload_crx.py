#!/usr/bin/env python
# origin: http://coreygoldberg.blogspot.com/2018/09/python-using-chrome-extensions-with.html
import os
from selenium import webdriver
from selenium.webdriver.chrome.options import Options


if __name__ == '__main__':
  if getenv('OS') != None :
    homedir = getenv('USERPROFILE').replace('\\', '/')
  else:
    homedir = getenv('HOME')
  extension = 'cropath.crx'# download archive
  packed_extension_path = '{0:s}/Downloads/{1:s}'.format(homedir, extention)
  options = Options()
  options.add_extension(packed_extension_path)
  # driver = webdriver.Chrome(options = options)

  # develper extension project
  unpacked_extension_path = os.path.abspath('chrome_extension_project')
  options.add_argument('--load-extension={}'.format(unpacked_extension_path))
  driver = webdriver.Chrome(options = options)

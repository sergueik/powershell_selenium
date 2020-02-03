#!/usr/bin/env python
# -*- coding: utf-8 -*-


import sys
from os import getenv
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import NoAlertPresentException
from selenium.common.exceptions import TimeoutException

if __name__ == '__main__':
  driver = webdriver.Firefox()
  driver.maximize_window()
  if getenv('OS') != None :
    homedir = getenv('HOMEDIR').replace('\\', '/')
  else:
    homedir = getenv('HOME')
  location = 'file:///{0}/{1}'.format('{0}/Downloads'.format(homedir),'text.html')
  driver.get(location)
  try:
    element = driver.find_element_by_xpath('//div[@id="up_file_name"]/label')
    print(element.text)
    assert element.text.encode('utf8','ignore') == unicode('Ошибка: неверный формат файла')
    # See also: http://translit-online.ru
    # Warning: Unicode equal comparison failed to convert both arguments to Unicode - interpreting them as being unequal
    print(element.text)
  except ( TimeoutException) as e:
    print('Element is not present'.format(e))
    print (e.args)
  finally:
    driver.quit()

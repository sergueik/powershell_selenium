#!/usr/bin/env python
# -*- coding: utf-8 -*-
# origin: https://www.techbeamers.com/selenium-webdriver-waits-python/
# see also:
# https://selenium-python.readthedocs.io/waits.html
# https://nedbatchelder.com/text/unipain.html

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
  xpath = '//div[@id="up_file_name"]/label'
  expected_text = u'Ошибка: неверный формат файла'
  try:
    WebDriverWait(driver,10).until(EC.visibility_of_element_located((By.XPATH, xpath)))
    element = driver.find_element_by_xpath(xpath )
    assert element.text.encode('utf8','ignore').decode('utf8') == expected_text
    print('Verified Text of Element: "{0}"'.format(element.text.encode('utf8','ignore')) )

  except ( TimeoutException) as e:
    print('Element is not located: '.format(e))
    print (e.args)
  finally:
    driver.quit()


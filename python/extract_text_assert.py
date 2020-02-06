#!/usr/bin/env python
# -*- coding: utf-8 -*-
# origin: https://www.techbeamers.com/selenium-webdriver-waits-python/
# see also:
# https://selenium-python.readthedocs.io/waits.html
# https://nedbatchelder.com/text/unipain.html
# https://pypi.org/project/transliterate/
# https://pythonhosted.org/cyrtranslit/
import sys
import os
import re
from os import getenv
import cyrtranslit
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException

# based on: http://www.cyberforum.ru/python/thread2218731.html
# not working
def transliteration(text):
    cyrillic = 'абвгдеёжзийклмнопрстуфхцчшщъыьэюя'
    latin = 'a|b|v|g|d|e|e|zh|z|i|i|k|l|m|n|o|p|r|s|t|u|f|kh|tc|ch|sh|shch||y||e|iu|ia'.split('|')
    trantab = {k:v for k,v in zip(cyrillic,latin)}
    newtext = ''
    for ch in text:
        # print('Converting: "{}"'.format(ch))
        casefunc =  str.capitalize if ch.isupper() else str.lower
        newtext += casefunc(trantab.get(ch.lower(),ch))
    return newtext

if __name__ == '__main__':
  os.environ['PYTHONIOENCODING'] = 'utf-8'
  # sys.setdefaultencoding('utf-8')
  driver = webdriver.Firefox()
  driver.maximize_window()
  if getenv('OS') != None :
    homedir = getenv('USERPROFILE').replace('\\', '/')
  else:
    homedir = getenv('HOME')
  location = 'file:///{0}/{1}'.format('{0}/Downloads'.format(homedir), 'localized_text.html')
  driver.get(location)
  xpath = '//div[@id="up_file_name"]/label'
  expected_text = u'Ошибка: неверный формат файла (разрешённые форматы: doc, docx, pdf, txt, odt, rtf).'
  try:
    WebDriverWait(driver,10).until(EC.visibility_of_element_located((By.XPATH, xpath)))
    element = driver.find_element_by_xpath(xpath)
    converted_text = element.text.encode('utf8','ignore').decode('utf8')
    assert converted_text == expected_text
    print('Verified Text of Element: "{}"'.format(element.text.encode('utf8','ignore')))

    # Unicode matches -  ot currently working
    match = re.match(r'^([\w]+) .*$', converted_text, re.UNICODE)
    if match == None:
      print('No Match.')
    else:
      print('Match: {}'.format(match.group()))

    m = re.match(r'^(Ошибка).*$', converted_text, re.UNICODE)
    if match == None:
      print('No Match.')
    else:
      print('Match: {}'.format(match.group()))

    # Use cyrtranslit to avoid dealing with Unicode
    translit_text = cyrtranslit.to_latin(element.text.encode('utf8','ignore'), 'ru')
    print('Cyr translit: "{}"'.format(translit_text))

    expected_text_fragment = u'Ошибка: неверный формат файла'
    translit_expected_text_fragment = cyrtranslit.to_latin(expected_text_fragment.encode('utf8','ignore'), 'ru')
    print('Cyr translit of expected: "{}"'.format(translit_expected_text_fragment ))

    match = re.match(r'^({}) .*$'.format(translit_expected_text_fragment  ), translit_text, re.UNICODE|re.M)
    if match == None:
      print('No Match.')
    else:
      # TypeError: group() takes no keyword arguments ?!
      print('Match (cyr translit): {}'.format(match.group(0)))

    transliteration_text = transliteration(element.text.encode('utf8','ignore'))
    print('Trans literared (alternative): "{}"'.format(transliteration_text))

  except ( TimeoutException) as e:
    print('Element is not located: '.format(e))
    print (e.args)
  finally:
    driver.quit()


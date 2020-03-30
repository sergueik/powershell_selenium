#!/usr/bin/env python3

from __future__ import print_function
import os
import sys
import re
import time
from os import getenv
from selenium import webdriver
from selenium.common.exceptions import WebDriverException
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions
from selenium.webdriver.chrome.options import Options

def wait_for_correct_current_url(wait , desired_url):
  wait.until(
    lambda driver: driver.current_url == desired_url)

is_windows = getenv('OS') != None and re.compile('.*NT').match( getenv('OS'))
homedir = getenv('USERPROFILE' if is_windows else 'HOME')
# sprint('user home directory path: {}'.format(homedir))

chromedriver_path = homedir + os.sep + 'Downloads' + os.sep + ('chromedriver.exe' if is_windows else 'chromedriver')
options = Options()
try:
  driver = webdriver.Chrome(executable_path = chromedriver_path, options = options)
except WebDriverException,e:
  driver = None
  print(e)
  pass
  # unknown error: Could not remove old devtools port file. Perhaps the given user-data-dir at ... is still attached to a running Chrome or Chromium process
if driver != None:
  driver.get('http://www.seleniumeasy.com/test')

url = 'https://www.seleniumeasy.com/test/input-form-demo.html'
driver.get(url)
wait = WebDriverWait(driver, 10)
wait_for_correct_current_url(wait, url)
# print('Title:{}'.format( driver.title))
title = 'Selenium Easy - Input Form Demo with Validations'
wait.until(expected_conditions.title_contains(title))
# wait.until(expected_conditions.title_is(title))
text = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor'
# based on: https://github.com/selenide/selenide/blob/master/src/main/java/com/codeborne/selenide/commands/SetValue.java
script = """
var setValue = function(element, text) {
    if (element.getAttribute('readonly') != undefined) return 'Cannot change value of readonly element';
    if (element.getAttribute('disabled') != undefined) return 'Cannot change value of disabled element';
    element.focus();
    var maxlength = element.getAttribute('maxlength') == null ? -1 : parseInt(element.getAttribute('maxlength'));
    element.value = maxlength == -1 ? text : text.length <= maxlength ? text : text.substring(0, maxlength);
    return null;
}

var element = arguments[0];
var text = arguments[1];

setValue(element, text);
return;
"""
# element = driver.find_element_by_xpath(xpath)

selector = 'form#contact_form > fieldset div.form-group div.input-group textarea.form-control'
element = driver.find_element_by_css_selector(selector)
# print(element.get_attribute('outerHTML'))
driver.execute_script(script, element,text)

time.sleep(10)
driver.close()
driver.quit()

# on vanilla Windows node
# PATH=%PATH%;c:\Python27;%USERPROFILE%\Downloads


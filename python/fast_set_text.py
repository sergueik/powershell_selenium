#!/usr/bin/env python

# based on: https://github.com/selenide/selenide/blob/master/src/main/java/com/codeborne/selenide/commands/SetValue.java
import sys
from os import getenv
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.firefox.options import Options
from selenium.webdriver.firefox.firefox_binary import FirefoxBinary
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.actions.interaction import KEY
from selenium.webdriver.common import keys

import time, datetime, os
from os import getenv
if __name__ == '__main__':
  options = Options()
  # options.headless = True
  binary = FirefoxBinary('/usr/bin/firefox')
  driver = webdriver.Firefox(firefox_binary = binary, executable_path = '{}/Downloads/geckodriver'.format(getenv('HOME')), options = options)
  # driver.maximize_window()
  # Sets the width and height of the browser window
  driver.set_window_size(1366, 768)
  text = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum'
  # Open the URL
  url = 'https://www.seleniumeasy.com/test/input-form-demo.html'
  driver.get(url)

  # set timeouts
  driver.set_script_timeout(30)
  driver.set_page_load_timeout(30) # seconds

  selector = 'form#contact_form > fieldset div.form-group div.input-group textarea.form-control'
  WebDriverWait(driver,10).until(EC.visibility_of_element_located((By.CSS_SELECTOR, selector)))
  element = driver.find_element_by_css_selector(selector)
  script = '''
    var setValue = function(element, text) {
      if (element.getAttribute('readonly') != undefined) return 'Cannot change value of readonly element';
      if (element.getAttribute('disabled') != undefined) return 'Cannot change value of disabled element';
      element.focus();
      var maxlength = element.getAttribute('maxlength') == null ? -1 : parseInt(element.getAttribute('maxlength'));
      element.value = maxlength == -1 ? text : text.length <= maxlength ? text : text.substring(0, maxlength);
      return null;
    };
    var element = arguments[0];
    var text = arguments[1];
    var debug = arguments[2];

    setValue(element, text);
    return;
'''
  driver.execute_script(script, element, text)
  print ('value:{}'.format(element.get_attribute('value')))
  time.sleep(10)
  script = '''
    var setValue = function(element, text) {
      if (element.getAttribute('readonly') != undefined) return 'Cannot change value of readonly element';
      if (element.getAttribute('disabled') != undefined) return 'Cannot change value of disabled element';
      element.focus();
      var maxlength = element.getAttribute('maxlength') == null ? -1 : parseInt(element.getAttribute('maxlength'));
      element.value = maxlength == -1 ? text : text.length <= maxlength ? text : text.substring(0, maxlength);
      return null;
    };
    var selector = arguments[0];
    var text = arguments[1];
    var debug = arguments[2];
    var nodes = window.document.querySelectorAll(selector);
    if (nodes) {
      setValue(nodes[0], text);
    }
    return;
'''
  text  = text[::-1]
  driver.execute_script(script, selector, text)
  print ('value:{}'.format(element.get_attribute('value')))
  time.sleep(10)
  # quit driver
  driver.close()
  driver.quit()

#!/usr/bin/env python3

# see https://developer.mozilla.org/en-US/docs/Web/API/Document/evaluate
# https://stackoverflow.com/questions/12215170/ownerdocument-property-of-node-is-null

from selenium import webdriver
from selenium.webdriver.firefox.options import Options

import sys, time, datetime
import getopt
import os
import json
if os.getenv('OS') != None :
  homedir = os.getenv('USERPROFILE').replace('\\', '/')
  geckodriver = 'geckodriver.exe'
else:
  homedir = os.getenv('HOME')
  geckodriver = 'geckodriver'

options = Options()
options.headless = True

binary = '{}/Downloads/firefox/firefox'.format(homedir)
# this assumes some latest Mozilla is downloaded and expanded in Downloads directory
# when not there, typical error is:
# Unable to find a matching set of capabilities
# use system default:
binary = '/usr/bin/firefox'
driver = '{}/Downloads/{}'.format(homedir, geckodriver)
# print ('starting: webdriver.firefox({},{},{})'.format(binary, driver, options))
driver = webdriver.Firefox(firefox_binary = binary, executable_path = driver, firefox_options = options )

url = 'file:///{0}/{1}'.format(os.getcwd(), 'data_image.html')
script1 = '''
var path = arguments[0];
var element = null;
try {
  var element = document.evaluate(path, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
  if (element) {
    // cannot actually return element directly to Python: it tries to load it indeed like an org.w3c.dom.Attr, which it is. The problem manifests  via
    // Exception: Message: TypeError: node.ownerDocument is null
    // TODO: hackaround by setting node.ownerDocument to something
    return element;
  }
} catch (e) {
  return "Script exception: " + e.toString()
}
'''
script2 = '''
var path = arguments[0];
var element = null;
try {
  var element = document.evaluate(path, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
  if (element) {
    var result = {};
    for (p in element) {
      console.log(p);
      result[p] = element[p];
     }
     return JSON.stringify(result);
  }
} catch (e) {
  return "Script exception: " + e.toString()
}
'''
driver.get(url = url)
time.sleep(1)
xpath =  "//img[@id='data_image']"
print('navigated to {}'.format(driver.current_url))
element = driver.find_element_by_xpath(xpath)
print('find element by xpath result: {}'.format((element.get_attribute('src'))[0:30]))
try:
  result = driver.execute_script(script1, "{0}/@src".format(xpath))
  print('invoke js (1)result: {}'.format(result))

  # TODO: does it not work just with Firefox or overall?
  # TypeError: node.ownerDocument is null
except Exception as e:
  print('Exception: {}'.format(e))
  script = script2
  result = driver.execute_script(script2, "{0}/@src".format(xpath))
  # convert JSON to hash
  print('invoke js (2) result: {}'.format(json.loads(result)['nodeValue'][0:30]))
except Exception as e:
  print('Exception: {}'.format(e))

finally:
  driver.close()
  driver.quit()


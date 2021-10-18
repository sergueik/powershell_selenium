#!/usr/bin/env python3

from selenium import webdriver
from selenium.webdriver.firefox.options import Options
from selenium.webdriver.firefox.firefox_binary import FirefoxBinary
import time, datetime, os,sys
import getopt
try:
  opts, args = getopt.getopt(sys.argv[1:], 'hds:o:', ['help', 'debug', 'search=', 'output='])
except getopt.GetoptError as err:
  print('usage: print_pdf.py --search <text> --output <output file>')
text = None
outpu_file = None
global debug
debug = False
for option, argument in opts:
  if option == '-d':
    debug = True
  elif option in ('-h', '--help'):
    print('usage: print_pdf.py --search <text> --output <output file>')
    exit()
  elif option in ('-s', '--search'):
    text = argument
  elif option in ('-o', '--output'):
    output_file = argument
  else:
    assert False, 'unhandled option: {}'.format(option)
if text == None or output_file == None:
  print('usage: print_pdf.py --search <text> --output <output file>')
  exit()

options = Options()
options.headless = True
binary = FirefoxBinary('/usr/bin/firefox')

# browser = webdriver.Firefox()
browser = webdriver.Firefox(firefox_binary = binary, executable_path = '{}/Downloads/geckodriver'.format(os.getenv('HOME')), options = options)

# Sets the width and height of the current window
browser.set_window_size(1366, 768)

# Open the URL
browser.get('https://www.youtube.com')

# set timeouts
browser.set_script_timeout(10)
browser.set_page_load_timeout(10)
# interesting on the youtube page there are multiple elements with id 'search':
element = browser.find_element_by_id('search')
print(element.get_attribute('outerHTML'))
# <g id="search"><path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"></path></g>
element = browser.find_element_by_css_selector('form input#search')
print(element.get_attribute('outerHTML'))
# <input id="search" autocapitalize="none" autocomplete="off" autocorrect="off" name="search_query" tabindex="0" type="text" spellcheck="false" placeholder="Search" aria-label="Search">
if element.get_attribute('type') == 'text':
  # https://github.com/SeleniumHQ/selenium/blob/master/py/selenium/webdriver/remote/webelement.py#503
  # see also
  # https://github.com/SeleniumHQ/selenium/blob/trunk/py/selenium/webdriver/common/actions/key_actions.py#39
  element.send_keys( text )
  browser.execute_script("""var element = arguments[0];
 element.dispatchEvent(new Event('input'));
""", element)
  browser.execute_script("""var element = arguments[0];
  element.dispatchEvent(new Event('change'));
""", element)

# Take screenshot
browser.save_screenshot(output_file)

# quit browser
browser.quit()


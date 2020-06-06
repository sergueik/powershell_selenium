from __future__ import print_function
# SyntaxError: from __future__ imports must occur at the beginning of the file
# based on: https://qna.habr.com/q/786911
import clipboard
# https://pypi.org/project/clipboard/
# claims to work for Windows, Mac and Linux
# https://github.com/asweigart/pyperclip
import sys
from os import getenv
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as ec

if getenv('OS') != None :
  homedir = getenv('USERPROFILE').replace('\\', '/')
else:
  homedir = getenv('HOME')

# alternatively PATH=%PATH%;%USERPROFILE%\Downloads
options = Options()
# NOTE:  clipboard manipulation only works in visual mode
# options.add_argument('--headless')
# options.add_argument('--disable-gpu')

# NOTE:TypeError: __init__() got an unexpected keyword argument 'chromedriver'
# the 'chromedriver' is not a keyword arg here
driver = webdriver.Chrome(homedir + '/' + 'Downloads' + '/' + 'chromedriver', options = options)

driver.get("https://yandex.ru/chat/#/chats/1%2F0%2Fccb05ef5-1472-4e50-a926-602807a6ef94")
elements_xpath = '//div[contains(@class, "yamb-message-balloon")]'
WebDriverWait(driver, 10).until(ec.presence_of_all_elements_located((By.XPATH, elements_xpath)))


elements = driver.find_elements_by_xpath(elements_xpath)

try:
  # object has no attribute 'clear'
  clipboard.copy('')
except Exception, e:
  print('Exception (ignored): {}'.format(e), file = sys.stderr)
  pass


# a.k.a. Actions in java
actionChains = ActionChains(driver)
actionChains.context_click(elements[4]).perform()
get_link_text = 'Get message link'
driver.find_element_by_xpath("//span[text()='{}']/..".format(get_link_text)).click()

# only on Windows
try:
  text = clipboard.paste() # text will have the content of clipboard
# except:
except Exception, e:
  # Pyperclip could not find a copy/paste mechanism for your system.
  # Possibly missing
  # sudo apt-get install -qy xclip xsel
  print('Exception (ignored): {}'.format(e), file = sys.stderr)
  pass
if text != None and text != '':
  print('Received through clipboard: {}'.format(text))
else:
  print('Failed to copy/paste through clipboard', file = sys.stderr)
driver.quit()



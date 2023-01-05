#!/usr/bin/env python
# -*- coding: utf-8 -*-

# based on: https://stackoverflow.com/questions/74793705/how-to-load-chrome-options-using-undetected-chrome
# uses CDP to override the user agent header
# see also:

import time,os,sys
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import json, base64

def send_command_return_result(driver, cmd, params = {}, resultkey = 'windowId'):
  post_url = driver.command_executor._url + '/session/{0:s}/chromium/send_command_and_get_result'.format( driver.session_id)
  response = driver.command_executor._request('POST', post_url, json.dumps({'cmd': cmd, 'params': params}))
  print('response: {}'.format(response))
  if ('status' in response ) and response['status']:
    raise Exception(response.get('value'))
  return response.get('value').get(resultkey)
   
def send_command(driver, cmd, params = {}):
  post_url = driver.command_executor._url + '/session/{0:s}/chromium/send_command_and_get_result'.format( driver.session_id)
  response = driver.command_executor._request('POST', post_url, json.dumps({'cmd': cmd, 'params': params}))
  if ('status' in response ) and response['status']:
    raise Exception(response.get('value'))
   

global debug
debug = False
if __name__ == '__main__':

  webdriver_options = Options()
  # comment to see the browser window
  webdriver_options.add_argument('--headless')
  webdriver_options.add_argument('--disable-gpu')
  # for annotated list of chrome headless flags, see
  # https://peter.sh/experiments/chromium-command-line-switches/
  # https://groups.google.com/forum/#!topic/selenium-users/SnxpvG8Erj4
  flags = [
    '--data-path=/tmp/data-path',
    '--disable-background-timer-throttling',
    '--disable-breakpad',
    '--disable-client-side-phishing-detection',
    '--disable-cloud-import',
    '--disable-default-apps',
    '--disable-dev-shm-usage', 
    '--disable-extensions',
    '--disable-gesture-typing',
    '--disable-gpu',
    '--disable-hang-monitor',
    '--disable-infobars',
    '--disable-notifications',
    '--disable-offer-store-unmasked-wallet-cards',
    '--disable-offer-upload-credit-cards',
    '--disable-popup-blocking',
    '--disable-print-preview',
    '--disable-prompt-on-repost',
    '--disable-setuid-sandbox',
    '--disable-speech-api',
    '--disable-sync',
    '--disable-tab-for-desktop-share',
    '--disable-translate',
    '--disable-voice-input',
    '--disable-wake-on-wifi',
    '--disable-webgl',
    '--disk-cache-dir=/tmp/cache-dir',
    '--enable-async-dns',
    '--enable-simple-cache-backend',
    '--enable-tcp-fast-open',
    '--headless',
    '--hide-scrollbars',
    '--homedir=/tmp',
    '--ignore-gpu-blacklist',
    '--media-cache-size=33554432',
    '--metrics-recording-only',
    '--mute-audio',
    '--no-default-browser-check',
    '--no-first-run',
    '--no-pings',
    '--no-sandbox',
    '--no-zygote',
    '--password-store=basic',
    '--prerender-from-omnibox=disabled',
    '--remote-debugging-port=9222',
    '--single-process',
    '--use-mock-keychain',
    '--user-data-dir=/tmp/user-data',
    '--window-size={}'.format(os.getenv('WINDOW_SIZE'))
  ]
  if os.getenv('OS') != None :
    homedir = os.getenv('USERPROFILE').replace('\\', '/')
    is_windows = True
  else:
    homedir = os.getenv('HOME')
    is_windows = False
  chromedriver_path = homedir + os.sep + 'Downloads' + os.sep + ('chromedriver.exe' if is_windows else 'chromedriver') 
  driver = webdriver.Chrome(chromedriver_path, options = webdriver_options)
  # https://chromedevtools.github.io/devtools-protocol/tot/Network/#method-setUserAgentOverride
  send_command(driver,
    'Network.setUserAgentOverride', {
      'userAgent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:72.0) Gecko/20100101 Firefox/72.0',
    }
  
  )
  url = 'https://www.whatismybrowser.com/detect/what-http-headers-is-my-browser-sending'
  driver.get(url)
  time.sleep(5)
  xpath = '//*[@id="content-base"]//table//th[contains(text(),"USER-AGENT")]/../td'
  element = driver.find_element_by_xpath(xpath)
  print( element.get_attribute('innerHTML'))

  driver.quit()


# PATH=%PATH%;c:\Python381;%USERPROFILE%\Downloads

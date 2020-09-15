#!/usr/bin/env python
# -*- coding: utf-8 -*-
# base on: https://github.com/hassaanaliw/chromepass/blob/mter/chromepass.py
# see also: https://github.com/darkarp/chromepas

import os
import sys
import sqlite3
import csv
import json
import struct
import argparse

try:
  import win32crypt  # python -m pip install pywin32
except:
  pass

def args_parser():

  parser = argparse.ArgumentParser( description = 'Retrieve Google Chrome Passwords')
  parser.add_argument('-o', '--output', choices = ['csv', 'json'], help = 'Output passwords to [ CSV | JSON ] format')
  parser.add_argument('-b', '--browser', choices = ['vivaldi', 'chrome', 'none'], help = 'Browser ("chrome" is default)')
  parser.add_argument('-d', '--dump', help = 'Dump passwords to stdout', action = 'store_true')
  parser.add_argument('-u', '--url', help = 'Filter passwords by url', type=str)

  browser = 'chrome'
  args = parser.parse_args()

  if args.url != None:
    url = args.url
  else:
    url = ''
  if args.browser != None:
    browser = args.browser

  print ('Processing browser {}'.format(browser))
  if args.dump:
    for data in main(browser, url):
      print(data)
  if args.output == 'csv':
    output_csv(main(browser, url))
    return

  if args.output == 'json':
    output_json(main(browser, url))
    return

  else:
    parser.print_help()

# http://zetcode.com/db/sqlitepythontutorial/
def main(browser = None, url = ''):
  if (os.name == 'posix') and (sys.platform == 'darwin'):
    print('Mac OSX not supported.')
    sys.exit(0)
  data = []
  appdata_path = get_appdata_path(browser)
  database = appdata_path + 'Login Data'
  try:
    print('Loading path: "{}"'.format(database))
    connection = sqlite3.connect(database)
    with connection:
      cursor = connection.cursor()
      cursor.execute( 'SELECT action_url, username_value, password_value, hex(password_value) FROM logins')

      while True:
        row = cursor.fetchone()

        if row == None:
            break

        # TypeError: tuple indices must be integers, not str
        # origin_url = row['action_url']
        # username = row['username_value']
        # password = row['password_value']
        origin_url = row[0]
        username = row[1]
        password = row[2]
        password_hex = row[-1]

        if os.name == 'nt':
          # uint dwFlags = CAPI.CRYPTPROTECT_UI_FORBIDDEN | CAPI.CRYPTPROTECT_LOCAL_MACHINE
          password = win32crypt.CryptUnprotectData( password, None, None, None, 1)[1]
        if url != '':
          if origin_url != None:
            if origin_url.__contains__(url):
              skip_flag = False
            else:
              skip_flag = True
          else:
            skip_flag = True
          if skip_flag:
            continue
        if password:
          data.append({
            'url': origin_url,
            'user': username,
            'password': str(password),
            'password_hex': password_hex
          })
        # TODO: convert password_hex to bytes
        # https://stackoverflow.com/questions/21017698/converting-int-to-bytes-in-python-3
    return data
  except sqlite3.OperationalError as e:
    e = str(e)
    if (e == 'database is locked'):
      print('Make sure browser {} is not running in the background'.format(browser))
    elif (e == 'no such table: logins'):
      print('Something wrong with the database name')
    elif (e == 'unable to open database file'):
      print('Something wrong with the database path')
    else:
      print(e)
    sys.exit(0)
  finally:
    if connection:
        connection.close()

def get_appdata_path(browser = 'chrome'):
  if os.name == 'nt':
    # Windows
    app_dir = {'chrome': 'Google\\Chrome', 'vivaldi': 'Vivaldi', 'none': 'None' }
    appdata_path = os.getenv('localappdata') + \
    '\\' + app_dir.get(browser) + \
      '\\User Data\\Default\\'
  elif os.name == 'posix':
    appdata_path = os.getenv('HOME')
    if sys.platform == 'darwin':
      # OS X
      appdata_path += '/Library/Application Support/Google/Chrome/Default/'
    else:
      # Linux
      app_dir = {'chrome': 'google-chrome', 'chromium': 'google-chrome', 'vivaldi': 'vivaldi', 'none': 'none' }
      appdata_path += '/.config/{}/Default/'.format(app_dir.get(browser))
  if not os.path.isdir(appdata_path):
    print("Application data directory of browser {} doesn\'t exists".format(browser))
    sys.exit(0)
  return appdata_path

def output_csv(info, filename = 'chromepass-passwords.csv'):
  try:
    with open(filename, 'wb') as csv_file:
      csv_file.write('url,user,password\n'.encode('utf-8'))
      for data in info:
        # one too many UTF-8 conversions ?
        # TypeError: a bytes-like object is required, not 'str'
        csv_file.write(("%s, %s, %s\n" % (data['url'], data['user'], data['password'])).encode('utf-8'))
    print('Data written to chromepass-passwords.csv')
  except EnvironmentError:
    print('EnvironmentError: cannot write data to {}'.format(filename))

def output_json(data, filename = 'chromepass-passwords.json'):
  try:
    with open(filename, 'w') as json_file:
      json.dump({'password_items': data}, json_file)
      print('Data written to {0}'.format(filename))
  except EnvironmentError:
    print('EnvironmentError: cannot write data to {}'.format(filename))

if __name__ == '__main__':
  args_parser()

# path=%path%;c:\Python27
# del *passwords.*

#!/usr/bin/env python
# -*- coding: utf-8 -*-
# based on: https://github.com/hassaanaliw/chromepass/blob/mter/chromepass.py
# see also: https://stackoverflow.com/questions/61099492/chrome-80-password-file-decryption-in-python
# see also: https://github.com/darkarp/chromepas

import os
import io
# see https://stackoverflow.com/questions/25049962/is-encoding-is-an-invalid-keyword-error-inevitable-in-python-2-x
# really need to run this in Python 3.x
import sys
import sqlite3
import csv
import json
import struct
import argparse
import traceback

import base64
from Crypto.Cipher import AES
# pip install pycryptodome
import shutil

try:
  import win32crypt
  # python -m pip install pywin32
except:
  pass


def get_master_key(database):
  print('Reading {}'.format(database))
  # UnicodeDecodeError: 'charmap' codec can't decode byte 0x90 in position 99: character maps to <undefined>
  # with io.open(database, 'r') as f:
  # UnicodeDecodeError: 'utf16' codec can't decode bytes in position 38924-38925: illegal UTF-16 surrogate
  # with io.open(database, 'r', encoding='utf-16') as f:
  # with open(os.environ['USERPROFILE'] + os.sep + r'AppData\Local\Google\Chrome\User Data\Local State', "r", encoding='utf-8') as f:
  # UnicodeDecodeError: 'utf8' codec can't decode byte 0x90 in position 99: invalid start byte
  with open(database, 'r', encoding='utf-8') as f:
  # print('Reading {}'.format(os.environ['USERPROFILE'] + os.sep + r'AppData\Local\Google\Chrome\User Data\Local State'))
  # with open(os.environ['USERPROFILE'] + os.sep + r'AppData\Local\Google\Chrome\User Data\Local State', "r", encoding='utf-8') as f:
    local_state = f.read()
    local_state = json.loads(local_state)
  master_key = base64.b64decode(local_state["os_crypt"]["encrypted_key"])
  master_key = master_key[5:]  # removing DPAPI prefix
  master_key = win32crypt.CryptUnprotectData(master_key, None, None, None, 0)[1]
  return master_key

def decrypt_payload(cipher, payload):
  return cipher.decrypt(payload)


def generate_cipher(aes_key, iv):
  return AES.new(aes_key, AES.MODE_GCM, iv)

def decrypt_password_chrome80(buff, master_key) -> bytes:
  try:
    iv = buff[3:15]
    payload = buff[15:]
    cipher = generate_cipher(master_key, iv)
    decrypted_pass = decrypt_payload(cipher, payload)
    decrypted_pass = decrypted_pass[:-16].decode()  # remove suffix bytes
    return decrypted_pass
  except Exception as e:
    #
    print("Probably saved password from Chrome version older than v80\n")
    # print(str(e))
    return bytearray([]) # Chrome < 80

def args_parser():

  parser = argparse.ArgumentParser( description = 'Retrieve Google Chrome Passwords')
  parser.add_argument('-o', '--output', choices = ['csv', 'json'], help = 'Output passwords to [ CSV | JSON ] format')
  parser.add_argument('-b', '--browser', choices = ['vivaldi', 'chrome', 'none'], help = 'Browser ("chrome" is default)')
  parser.add_argument('-p', '--dump', help = 'Dump passwords to stdout', action = 'store_true')
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
        print(json.dumps(data, indent = 2))
    if args.output == 'csv':
      output_csv(main(browser, url))
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
  browserdata_path = get_browserdata_path(browser)
  if os.name == 'nt':
    state_database = browserdata_path + '\\Local State' # TODO: use os.sep
    login_database = browserdata_path + '\\Default\\Login Data'
  else:
    state_database = browserdata_path + '/Local State'
    login_database = browserdata_path + '/Default/Login Data'
  master_key = get_master_key(state_database)

  try:
    print('Loading path: "{}"'.format(login_database))
    connection = sqlite3.connect(login_database)
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
        encrypted_password = row[2]
        password_hex = row[-1]

        if os.name == 'nt':
          password = decrypt_password_chrome80(encrypted_password, master_key)
          if len(password) == 0:
            try:
              print('Trying legacy call for {}'.format(username))
              # uint dwFlags = CAPI.CRYPTPROTECT_UI_FORBIDDEN | CAPI.CRYPTPROTECT_LOCAL_MACHINE
              password = win32crypt.CryptUnprotectData( password, None, None, None, 1)[1]
            except (Exception) as e:
              # print(e.__class__.__name__)
              # print(traceback.format_exc())
              print('Exception (ignored): {}'.format(e), file = sys.stderr)
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
      print('Something wrong with the database tables')
    elif (e == 'unable to open database file'):
      print('Something wrong with the database path')
    else:
      print(e)
    sys.exit(0)
  finally:
    if connection:
        connection.close()

def get_browserdata_path(browser = 'chrome'):
  if os.name == 'nt':
    # Windows
    app_dir = {'chrome': 'Google\\Chrome', 'vivaldi': 'Vivaldi', 'none': 'None' }
    # NOTE: IndentationError: unindent does not match any outer indentation level
    browserdata_path = os.getenv('localappdata') + \
    '\\' + app_dir.get(browser) + \
    '\\User Data'
  elif os.name == 'posix':
    browserdata_path = os.getenv('HOME')
    if sys.platform == 'darwin':
      # OS X
      browserdata_path += '/Library/Application Support/Google/Chrome'
    else:
      # Linux
      app_dir = {'chrome': 'google-chrome', 'chromium': 'google-chrome', 'vivaldi': 'vivaldi', 'none': 'none' }
      browserdata_path += '/.config/{}'.format(app_dir.get(browser))
  if not os.path.isdir(browserdata_path):
    print("Application data directory {} of browser {} doesn\'t exists".format(browserdata_path, browser))
    sys.exit(0)
  return browserdata_path

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
    print('EnvironmentError: cannot save data to {}'.format(filename))

def output_json(data, filename = 'chromepass-passwords.json'):
  try:
    with open(filename, 'w') as json_file:
      json.dump({'password_items': data}, json_file)
      print('Data written to {0}'.format(filename))
  except EnvironmentError:
    print('EnvironmentError: cannot save data to {}'.format(filename))

if __name__ == '__main__':
  args_parser()
	
# path=%path%;c:\Python381;C:\python381\Scripts
# pip install pycryptodome
# del *passwords.*

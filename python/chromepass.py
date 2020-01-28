#!/usr/bin/env python
# -*- coding: utf-8 -*-
# base on: https://github.com/hassaanaliw/chromepass/blob/master/chromepass.py
# see also: https://github.com/darkarp/chromepass

import os
import sys
import sqlite3
import csv
import json
import argparse

try:
    import win32crypt  # python -m pip install pywin32
except:
    pass

def args_parser():

    parser = argparse.ArgumentParser(
        description='Retrieve Google Chrome Passwords')
    parser.add_argument('-o', '--output', choices=['csv', 'json'],
                        help='Output passwords to [ CSV | JSON ] format.')
    parser.add_argument('-b', '--browser', choices=['vivaldi', 'chrome', 'none'],
                        help='Browser ("chrome" is default).')
    parser.add_argument(
        '-d', '--dump', help='Dump passwords to stdout. ', action='store_true')
    browser = 'chrome'
    args = parser.parse_args()
    if args.browser != None:
        browser = args.browser
    if args.dump:
        for data in main(browser):
            print(data)
    if args.output == 'csv':
        output_csv(main(browser))
        return

    if args.output == 'json':
        output_json(main(browser))
        return

    else:
        parser.print_help()


def main(app = None):
    info_list = []
    path = getpath(app)
    try:
        connection = sqlite3.connect(path + 'Login Data')
        with connection:
            cursor = connection.cursor()
            v = cursor.execute(
                'SELECT action_url, username_value, password_value FROM logins')
            value = v.fetchall()

        if (os.name == 'posix') and (sys.platform == 'darwin'):
            print('Mac OSX not supported.')
            sys.exit(0)

        for origin_url, username, password in value:
            if os.name == 'nt':
                password = win32crypt.CryptUnprotectData(
                    password, None, None, None, 0)[1]

            if password:
                info_list.append({
                    'origin_url': origin_url,
                    'username': username,
                    'password': str(password)
                })

    except sqlite3.OperationalError as e:
        e = str(e)
        if (e == 'database is locked'):
            print('[!] Make sure Google Chrome is not running in the background')
        elif (e == 'no such table: logins'):
            print('[!] Something wrong with the database name')
        elif (e == 'unable to open database file'):
            print('[!] Something wrong with the database path')
        else:
            print(e)
        sys.exit(0)

    return info_list


def getpath(app = 'chrome'):
    app_path = {'chrome': 'Google\\Chrome', 'vivaldi': 'Vivaldi', 'none': 'None' }
    if os.name == 'nt':
        # Windows
        user_data_dir = os.getenv('localappdata') + \
        '\\' + app_path.get(app) + \
            '\\User Data\\Default\\'
    elif os.name == 'posix':
        user_data_dir = os.getenv('HOME')
        if sys.platform == 'darwin':
            # OS X
            user_data_dir += '/Library/Application Support/Google/Chrome/Default/'
        else:
            # Linux
            user_data_dir += '/.config/google-chrome/Default/'
    if not os.path.isdir(user_data_dir):
        print("User data directory of application {} doesn\'t exists".format(app))
        sys.exit(0)

    return user_data_dir


def output_csv(info):
    try:
        with open('chromepass-passwords.csv', 'wb') as csv_file:
            csv_file.write('origin_url,username,password \n'.encode('utf-8'))
            for data in info:
                csv_file.write(("%s, %s, %s \n" % (data['origin_url'], data[
                    'username'], data['password'])).encode('utf-8'))
        print('Data written to chromepass-passwords.csv')
    except EnvironmentError:
        print('EnvironmentError: cannot write data')


def output_json(info):
	try:
		with open('chromepass-passwords.json', 'w') as json_file:
			json.dump({'password_items':info},json_file)
			print('Data written to chromepass-passwords.json')
	except EnvironmentError:
		print('EnvironmentError: cannot write data')



if __name__ == '__main__':
    args_parser()
	


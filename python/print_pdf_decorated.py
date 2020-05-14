#!/usr/bin/env python3
# based on: https://groups.google.com/forum/#!topic/selenium-users/PuDpVblziAofrom __future__ import print_function
import getopt
import sys
import datetime
import re
from os import getenv
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import json, base64

class h1:

  def __init__(self, url, chromedriver, print_options):
    self.url = url
    self.chromedriver = chromedriver
    self.print_options = print_options


  my_date_time = datetime.datetime.now().strftime('%Y%m%d%H%M%S')

  def setup(self):
    """Executed before running tests"""

  def teardown(self):
    """Executed after running tests"""

  def test_decorator(func):
    """ setup, arange, act, assert, teardown """
    def wrapper(self, *args, **kwargs):
      print('executing {0}'.format(self.setup), file = sys.stderr)
      self.setup()
      print('executing {0}'.format(func), file = sys.stderr)
      func(self, *args, **kwargs)
      print('executing {0}'.format(self.teardown), file = sys.stderr)
      self.teardown()
    return wrapper

  @test_decorator
  def visit_site(self):
    result = self.print_pdf(url, homedir + '/' + 'Downloads' + '/' + 'chromedriver', print_options)
    with open(file = output_file, mode = 'wb') as f:
      f.write(result)


  def print_pdf(self, url, chromedriver = './chromedriver', print_options = {}):
    options = Options()
    options.add_argument('--headless')
    options.add_argument('--disable-gpu')
    driver = webdriver.Chrome(chromedriver, options = options)
    if debug:
      print('Loading url: "{}"'.format(url), file = sys.stderr)

    driver.get(url)
    params = {
      'landscape': False,
      'displayHeaderFooter': False,
      'printBackground': True,
      'preferCSSPageSize': False,
    }
    params.update(print_options)
    if debug:
      print('params: {}'.format(params))
    result = self.send_command_and_get_result(driver, 'Page.printToPDF', params)
    # print( result.keys())
    driver.quit()
    return base64.b64decode(result['data'])

  # https://stackoverflow.com/questions/47023842/selenium-chromedriver-printtopdf
  # https://www.python-course.eu/python3_formatted_output.php
  def send_command_and_get_result(self, driver, cmd, params = {}):
    post_url = driver.command_executor._url + '/session/{0:s}/chromium/send_command_and_get_result'.format( driver.session_id)
    if debug:
      print ('POST to {}'.format(post_url))
      print('params: {}'.format(json.dumps({'cmd': cmd, 'params': params})))

    response = driver.command_executor._request('POST', post_url, json.dumps({'cmd': cmd, 'params': params}))
    if debug:
      print( response.keys())
    # NOTE: 'has_key()' is even removed from P 3.x
    # see also: https://stackoverflow.com/questions/1323410/should-i-use-has-key-or-in-on-python-dicts
    # NOTE: KeyError: 'status'
    # early imlementation returns JSON with ['status', 'sessionId', 'value'] keys
    # with recent versions of chrome response contains only has ['value']['data']
    # print( response.keys())
    if ('status' in response ) and response['status']:
      raise Exception(response.get('value'))

    return response.get('value')
    # NOTE: on Windows 7 node occationally seeing commctl32.dll warning:
    # 'A program running on this computer is trying to display a message'
    # no meaningful message shown when 'View the Message' is chosen - repeated multiple times

if __name__ == '__main__':
  # https://docs.python.org/2/library/getopt.html
  try:
    opts, args = getopt.getopt(sys.argv[1:], 'hdi:o:s:p:', ['help', 'debug', 'input=', 'output=','size=', 'pages='])
  except getopt.GetoptError as err:
    print('usage: print_pdf.py --input <html page> --output <output file>')
    print(str(err))
    exit()

  output_file = None
  url = None
  paper_size = None
  pages = None
  global debug
  debug = False
  for option, argument in opts:
    if option == '-d':
      debug = True
    elif option in ('-h', '--help'):
      print ('usage: print_pdf.py --input <html page> --output <output file>')
      exit()
    elif option in ('-i', '--input'):
      url = argument
    elif option in ('-p', '--pages'):
      pages = argument
    elif option in ('-s', '--size'):
      paper_size = argument
    elif option in ('-o', '--output'):
      output_file = argument
    else:
      assert False, 'unhandled option: {}'.format(option)

  if url == None or output_file == None:
    print ('usage: print_pdf.py --input <html page> --output <output file>')
    exit()

  if getenv('OS') != None :
    homedir = getenv('USERPROFILE').replace('\\', '/')
  else:
    homedir = getenv('HOME')

  # NOTE:  when schema prefix is omitted from the url, an exception is raised:
  # selenium.common.exceptions.InvalidArgumentException:
  # Message: invalid argument (Session info: headless chrome=76.0.3809.100)
  match = re.match(r'^(https?://).*$', url, re.UNICODE)
  if match == None:
    url = 'https://{}'.format(url)

  match = None
  if paper_size != None:
    match = re.match(r'a4', paper_size, re.UNICODE|re.IGNORECASE  )
  if match == None:
    print_options = {}
  else:
    # specify custom page size (default is Letter), through dimensions
    print_options = {
      'paperWidth': 8.27,
      'paperHeight': 11.69,
    }
  if pages != None:
      print_options.update({'pageRanges': pages})
  if debug:
    print('opts: {}'.format(opts))
    # exit()
  helper = h1(url, homedir + '/' + 'Downloads' + '/' + 'chromedriver', print_options)
  helper.visit_site()




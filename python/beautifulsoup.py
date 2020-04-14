#!/usr/bin/env python3

from __future__ import print_function
import pprint
import time
import sys
from os import getenv, path, access, R_OK
import json, base64
import requests
from bs4 import BeautifulSoup as beautifulsoup
from requests.exceptions import InvalidSchema
# https://github.com/psf/requests/issues/2732
# https://stackoverflow.com/questions/10123929/fetch-a-file-from-a-local-url-with-python-requests/22989322#22989322

if sys.version_info.major < 3:
  from urllib import url2pathname
else:
  from urllib.request import url2pathname

class LocalFileAdapter(requests.adapters.BaseAdapter):

  @staticmethod
  def _chkpath(method, file_path):
    if method.upper() in ('PUT', 'DELETE'):
      return 501, 'Not Implemented'
    elif method.upper() not in ('GET', 'HEAD'):
      return 405, 'Not Allowed'
    elif path.isdir(file_path):
      return 400, 'Not A File'
    elif not path.isfile(file_path):
      return 404, 'File Not Found'
    elif not access(file_path, R_OK):
      return 403, 'Access Denied'
    else:
      return 200, 'OK'

  def send(self, req, **kwargs):

    file_path = path.normcase(path.normpath(url2pathname(req.path_url)))
    response = requests.Response()

    response.status_code, response.reason = self._chkpath(req.method, file_path)
    if response.status_code == 200 and req.method.lower() != 'head':
      try:
        response.raw = open(file_path, 'rb')
      except (OSError, IOError) as e:
        response.status_code = 500
        response.reason = str(e)

    if isinstance(req.url, bytes):
      response.url = req.url.decode('utf-8')
    else:
      response.url = req.url

    response.request = req
    response.connection = self

    return response

  def close(self):
    pass

def parser2(url = None, filename = None):
  file = open(filename, 'w')

  # page = requests.get(url)
  requests_session = requests.session()
  requests_session.mount('file://', LocalFileAdapter())
  page = requests_session.get(url)
  soup = beautifulsoup(page.content, 'html.parser')

  rows = []
  items = soup.find_all('div', class_ = 'rTableCell')

  for item in items:
    element = item.find('a')
    if element:
      rows.append({
        'title': element.get_text(strip = True),
        'link': element.get('href'),
      })
  pp = pprint.PrettyPrinter(indent = 2, stream = sys.stderr)
  for item in rows:
    pp.pprint(item)
    file.writelines("{} {}\n".format(item['title'],item['link']))
  file.close()

url ='file://{0}'.format(path.dirname(path.realpath(__file__)) + '/' + 'table.html' )
parser2(url, 'data.txt')

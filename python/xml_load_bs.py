# based on: https://www.cyberforum.ru/python-web/thread2666195.html
# https://linuxhint.com/parse_xml_python_beautifulsoup/

import requests
from bs4 import BeautifulSoup
url = 'http://econym.org.uk/gmap/states.xml'
html = requests.get(url)
soup = BeautifulSoup(html.text, 'lxml')
states = soup.find_all('state', attrs = {'name': True, 'colour':True})
 
result = {}
# use Python comprehensions to have code compact
for r in states:
  points = [(x['lat'], x['lng']) for x in r.find_all('point')]
  result[r['name']] = points
 
for data in result:
  print('{}: {}'.format(data, result[data]))


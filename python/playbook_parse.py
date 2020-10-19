#!/usr/bin/env python
# -*- coding: utf-8 -*-
# export PATH=$PATH:/usr/lib/python2.7/dist-packages/ansible
import yaml
import sys
import pprint
import re

DEBUG = False
pp = pprint.PrettyPrinter(indent = 2)
# TODO: captures values with a space inside single quotes  
# except leading and trailing space in the value
# pattern = re.compile(r"'([^=']+ [^=']+)'")
tokenizer_expression = "'(?P<word>[^=']+ [^=']+)'" # no need for 'raw'

playbook = yaml.load(open(sys.argv[1]))
# playbook = yaml.load(open(sys.argv[1]), Loader=yaml.FullLoader)
if DEBUG:
  pp.pprint(playbook)
tasks = playbook['tasks']
for cnt in range(len(tasks)):
  task = tasks[cnt]

  if DEBUG:
    pp.pprint(task['package'])
  try:
    data = task['package']
    if DEBUG:
      pp.pprint(data)
    
    pattern = re.compile(tokenizer_expression)
    total_cnt = 0
    new_data = data
    # https://stackoverflow.com/questions/3345785/getting-number-of-elements-in-an-iterator-in-python
    if DEBUG:
      for matches in re.finditer(pattern, data):
        total_cnt = total_cnt + 1
        print('found: "{}"'.format( matches.group(1)))
    else:
      total_cnt =  sum(1 for _ in re.finditer(pattern, data))
    for cnt in range(total_cnt):
      matches = pattern.search( data )
      if matches != None:
        word = matches.group('word')
        if ' ' in word:
          new_word = word.replace(' ', '0x20') 
          if DEBUG:
            print('processing "{}"'.format(word))
          new_data = data.replace("'{}'".format(word), "'{}'".format(new_word))
        else:
          new_data = data
      if DEBUG:    
        print('temporary data (iteration {}): "{}"'.format(cnt, new_data))
      data = new_data
    values = {}
    raw_values = dict(item.split('=') for item in new_data.split(' '))
    for k in raw_values:
      values[k] = raw_values[k].replace('0x20', ' ').replace("'", '')
    subkey = 'name'  
    print('{}="{}"'.format(subkey, values[subkey]))
  except TypeError as e:
    # TODO:  Python 2.7 compabile print to STDERR
    print(str(e))
    # print(str(e), file = sys.stderr)
    pass
  except ValueError as e:
    # TODO:  Python 2.7 compabile print to STDERR
    print(str(e))
    # print(str(e), file = sys.stderr)
    # TODO: ValueError: dictionary update sequence element #0 has length 3; 2 is required
    pass


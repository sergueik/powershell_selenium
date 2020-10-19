#!/usr/bin/env python3
# for python 2.7 need few modifications
#!/usr/bin/env python
# -*- coding: utf-8 -*-
# export PATH=$PATH:/usr/lib/python2.7/dist-packages/ansible
from __future__ import print_function
# NOTE: SyntaxError: from __future__ imports must occur at the beginning of the file
import yaml
# NOTE: ImportError: No module named 'yaml'
# there is no pyyaml in LibreOoffice embedded Python
# Windows (Python 2.7 intalled):
# path=%path%;c:\Python27;c:\Python27\scripts
# pip2 install pyyaml
#
# python3 launch_direct.py  --input classification.yaml  --environment prod  --datacenter eastcoast --role server
#    role="service-discovery-server-0"
#    datacenter="eastcoast"
#    environment="prod"
#
#    role="service-discovery-server-1"
#    datacenter="eastcoast"
#    environment="prod"

import getopt
import sys
import re
import pprint
from os import getenv
import json, base64

if __name__ == '__main__':
  pp = pprint.PrettyPrinter(indent=2)
  # https://docs.python.org/2/library/getopt.html
  try:
    opts, args = getopt.getopt(sys.argv[1:], 'hdi:e:c:r:', ['help', 'debug', 'input=', 'environment=','datacenter=', 'role='])

  except getopt.GetoptError as err:
    print('usage: launch_direct.py --input <classification file> --role <role> --environment <environment> --datacenter <datacenter>')
    print(str(err))
    exit()

  input_file = None
  datacenter = None
  environment = None
  role = None
  global debug
  debug = False
  for option, argument in opts:
    if option == '-d':
      debug = True
    elif option in ('-h', '--help'):
      print('usage: launch_direct.py --input <classification file> --role <role> --environment <environment> --datacenter <datacenter>')
      exit()
    elif option in ('-e', '--environment'):
      environment = argument
    elif option in ('-r', '--role'):
      role = argument
    elif option in ('-c', '--datacenter'):
      datacenter = argument
    elif option in ('-i', '--input'):
      input_file = argument
    else:
      assert False, 'unhandled option: {}'.format(option)

  if debug:
    print("input_file={}\nrole={}\ndatacenter={}\nenvironment={}".format(input_file,role,datacenter,environment))
  if input_file == None or role == None or datacenter == None or environment == None:
    print('usage: launch_direct.py --input <classification file> --role <role> --environment <environment> --datacenter <datacenter>')
    exit()

  classification = yaml.load(open(input_file), Loader=yaml.FullLoader)
  if debug:
    # print sample entry
    pp.pprint(classification[list(classification.keys())[0]])

  for host in classification:
    if debug:
      print('inspecting host: {0}'.format(host))
    host_data = classification[host]
    if debug:
      print('inspecting role: {0}'.format(classification[host]['role']))
    # https://stackoverflow.com/questions/33727149/dict-object-has-no-attribute-has-key
    # AttributeError: 'dict' object has no attribute 'has_key'
    if 'role' in host_data and re.match('^.*{}.*'.format(role), host_data['role']):
      if debug:
        print('inspecting datacenter: {0}'.format(classification[host]['datacenter']))
      if 'datacenter' in host_data and host_data['datacenter'] == datacenter:
        if debug:
          print('inspecting environment: {0}'.format(classification[host]['environment']))
        if 'environment' in host_data and re.match('^{}.*'.format(environment), host_data['environment']):
          if debug:
            print(host_data)

          print("role=\"{}\"\ndatacenter=\"{}\"\nenvironment=\"{}\"\n".format(host_data['role'],host_data['datacenter'],host_data['environment']))

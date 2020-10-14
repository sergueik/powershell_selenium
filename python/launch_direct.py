#!/usr/bin/env python3
from __future__ import print_function
# NOTE: SyntaxError: from __future__ imports must occur at the beginning of the file
import yaml
# NOTE: ImportError: No module named 'yaml'
# there is no pyyaml in LibreOoffice embedded Python
# Windows (Python 2.7 intalled):
# path=%path%;c:\Python27;c:\Python27\scripts
# pip2 install pyyaml
#
# python launch_direct.py -i classification.yaml -r service-discovery-server -e prod -c wec

import getopt
import sys
import re
from os import getenv
import json, base64

if __name__ == '__main__':
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
    print(classification['ad8c3125'])  

  for host in classification:
    host_data = classification[host]
    if host_data.has_key('role') and re.match('^{}.*'.format(role), host_data['role']):
      if host_data.has_key('datacenter') and host_data['datacenter'] == datacenter:
        # if host_data.has_key('environment') and host_data['environment'] == environment:
        if host_data.has_key('environment') and re.match('^{}.*'.format(environment), host_data['environment']):
          if debug:
            print(host_data)

          print("role=\"{}\"\ndatacenter=\"{}\"\nenvironment=\"{}\"\n".format(host_data['role'],host_data['datacenter'],host_data['environment']))

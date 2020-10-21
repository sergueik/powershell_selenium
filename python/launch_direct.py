#!/usr/bin/env python
# -*- coding: utf-8 -*-
#!/usr/bin/env python3
# for python 2.7 need few modifications
# on Windows machine
# PATH=%PATH%;c:\Python27;c:\Python27\Scripts
# export PATH=$PATH:/usr/lib/python2.7/dist-packages/ansible
from __future__ import print_function
# NOTE: SyntaxError: from __future__ imports must occur at the beginning of the file
import yaml
# NOTE: ImportError: No module named 'yaml'
# there is no pyyaml in LibreOoffice embedded Python
# Windows (Python 2.7 intalled):
# path=%path%;c:\Python27;c:\Python27\scripts
# pip2 install pyyaml
# python ...
# python3 launch_direct.py --input classification.yaml --debug --environment prod --datacenter eastcoast --role server --nodes e44820191,e44820192,e44820193 --password env:USERPROFILE
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
def get_column(argument):
  # dictionary of arguments to columns
  # TODO: dynamic pull of identical part
  argument_columns = {
    'role': 'consul_role'
  }
  # print('argument: {}'.format(argument))
  # print('argument_columns: {}'.format(argument_columns))
  if argument in argument_columns:
    return argument_columns.get(argument)
  else:
    return argument

def get_value(argument):
  if re.match('^env:*', argument):
    return getenv(re.sub('env:', '', argument))
  else:
    return argument

if __name__ == '__main__':
  pp = pprint.PrettyPrinter(indent=2)
  # https://docs.python.org/2/library/getopt.html
  try:
      opts, args = getopt.getopt(sys.argv[1:], 'hdi:e:c:r:n:p:', ['help', 'debug', 'input=', 'environment=','datacenter=', 'role=', 'nodes=', 'password='])

  except getopt.GetoptError as err:
    print('usage: launch_direct.py --input <classification file> --role <role> --environment <environment> --datacenter <datacenter>')
    print(str(err))
    exit()

  input_file = None
  datacenter = None
  environment = None
  password = None
  nodes = []
  role = None
  global debug
  debug = False
  for option, argument in opts:
    if option in ( '-d', '--debug'):
      debug = True
    elif option in ('-h', '--help'):
      print('usage: launch_direct.py --input <classification file> --role <role> --environment <environment> --datacenter <datacenter>')
      exit()
    elif option in ('-e', '--environment'):
      environment = argument
    elif option in ('-p', '--password'):
      password = get_value(argument)
    elif option in ('-n', '--nodes'):
      if debug:
         print("option:{}\nargument:{}".format(option,argument))
      if re.match('^@.*', argument):
        if debug:
           print("idenfified argument as file name:{}".format(argument))
        with open(re.sub('^@', '', argument), 'r') as argument_file:
          nodes = re.split(r'\W*\r?\n\W*', argument_file.read())
      else:
        nodes = re.split(r'\W*,\W*', argument) # NOTE: trailing space leftover possible
    elif option in ('-r', '--role'):
      role = argument
    elif option in ('-c', '--datacenter'):
      datacenter = argument
    elif option in ('-i', '--input'):
      input_file = argument
    else:
      assert False, 'unhandled option: {}'.format(option)
  if debug:
    print("input_file={}\nrole={}\ndatacenter={}\nenvironment={}\nnodes={}\npassword={}".format(input_file,role,datacenter,environment,nodes,password))
  if input_file == None or role == None or datacenter == None or environment == None:
    print('usage: launch_direct.py --input <classification file> --role <role> --environment <environment> --datacenter <datacenter>')
    exit()
  classification = yaml.load(open(input_file), Loader=yaml.FullLoader)
  if debug:
    # print sample entry
    pp.pprint(classification[list(classification.keys())[0]])

  for host,host_data in classification.iteritems():
    if debug:
      print('inspecting host: {0}'.format(host))
    role_column = get_column('role')
    if debug:
      # AttributeError: 'dict' object has no attribute 'role'
      # print('inspecting role: {0}'.format(host_data.role))
      print('inspecting role: {0}'.format(host_data.get(role_column)))
    # https://stackoverflow.com/questions/33727149/dict-object-has-no-attribute-has-key
    # AttributeError: 'dict' object has no attribute 'has_key'
    if role_column in host_data and re.match('^.*{}.*'.format(role), host_data[role_column]):
      if debug:
        print('inspecting datacenter: {0}'.format(host_data.get('datacenter')))
      if 'datacenter' in host_data and host_data['datacenter'] == datacenter:
        if debug:
          print('inspecting environment: {0}'.format(host_data.get('environment')))
        if 'environment' in host_data and re.match('^{}.*'.format(environment), host_data['environment']):
          if debug:
            print(host_data)

          print("role=\"{}\"\ndatacenter=\"{}\"\nenvironment=\"{}\"\n".format(host_data[role_column],host_data['datacenter'],host_data['environment']))

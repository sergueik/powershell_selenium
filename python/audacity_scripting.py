#!/usr/bin/env python
# based on: https://github.com/audacity/audacity/blob/master/scripts/piped-work/pipe_test.py
# -*- coding: utf-8 -*-
# path=%path%;c:\Program Files\LibreOffice\program;c:\Program Files\LibreOffice\program\python-core-3.5.5\bin

import os
import sys
import time

# windows
if sys.platform == 'win32':
  TONAME = '\\\\.\\pipe\\ToSrvPipe'
  FROMNAME = '\\\\.\\pipe\\FromSrvPipe'
  EOL = '\r\n\0'
# linux or mac
else:
  TONAME = '/tmp/audacity_script_pipe.to.' + str(os.getuid())
  FROMNAME = '/tmp/audacity_script_pipe.from.' + str(os.getuid())
  EOL = '\n'

if not os.path.exists(TONAME):
  print('Audacity is not running', file = sys.stderr)
  sys.exit()

if not os.path.exists(FROMNAME):
  print('Audacity is not running', file = sys.stderr)
  sys.exit()

time.sleep(1)
TOFILE = open(TONAME, 'w')
FROMFILE = open(FROMNAME, 'rt')


def send_command(command):
  """Send a single command."""
  print("Send: >>> \n"+command)
  TOFILE.write(command + EOL)
  TOFILE.flush()

def get_response():
  """Return the command response."""
  result = ''
  line = ''
  while True:
    result += line
    line = FROMFILE.readline()
    if line == '\n' and len(result) > 0:
      break
  return result

def do_command(command):
  """Send one command, and return the response."""
  send_command(command)
  response = get_response()
  print("Rcvd: <<< \n" + response)
  return response

  
# https://manual.audacityteam.org/man/scripting_reference.html
def quick_test():
  # do_command('Help: Command=Help')
  do_command('Help: Command="GetPreference"')
  do_command('GetPreference: Name="*"')
  #do_command('SetPreference: Name=GUI/Theme Value=classic Reload=1')

if len(sys.argv) > 1:
  filename = sys.argv[1]
  do_command('Import2: Filename="{}"'.format(filename))
  do_command('Export2:')
else:
  quick_test()


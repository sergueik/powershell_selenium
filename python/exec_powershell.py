# based on: https://stackoverflow.com/questions/21944895/running-powershell-script-within-python-script-how-to-make-python-print-the-pow
# -*- coding: iso-8859-1 -*-
from os import getenv
import subprocess, sys
# test.ps1
""""
# this is official notation. Note parameter index is zero based
param(
  [String][parameter(Position = 0)]$param1,
  [String][parameter(Position = 1)]$param2,
  [String][parameter(Position = 2)]$param3
)

<#
# this works too
param(
  [String] $param1,
  [String] $param2,
  [String] $param3
)

#>

write-output ('test params "{0}" "{1}" "{2}"' -f $param1, $param2, $param3)

"""
param1 = 'param1'
param2 = 'param2'

p = subprocess.Popen(['powershell.exe','{}\\Desktop\\test.ps1'.format(getenv('USERPROFILE')), param1, param2], stdout=sys.stdout)
p.communicate()

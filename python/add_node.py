#!/usr/bin/env python

# NOTE: xml.etree is part of stdlib - no need (or way) to pip install it
# https://stackoverflow.com/questions/34566142/cant-install-elementtree-with-pip
# based on question https://qna.habr.com/q/869443

from __future__ import print_function
import re
from os import getenv, path
import xml.etree.ElementTree as ET
import argparse

# https://docs.python.org/3/library/argparse.html
parser = argparse.ArgumentParser(prog = 'modify_web_xml')
parser.add_argument('--inputfile', '-i', help = 'input file')
parser.add_argument('--outputfile', '-o', help = 'output file', type = str, action = 'store')
parser.add_argument('--element_tagname', '-n', help = 'element tagname', type = str, action = 'store')
parser.add_argument('--element_class', '-c', help = 'element class', type = str, action = 'store')
parser.add_argument('--element_id', '-k', help = 'element id', type = str, action = 'store')
parser.add_argument('--element_text', '-t', help = 'element text', type = str, action = 'store')
parser.add_argument('--debug', '-d', help = 'debug', action = 'store_const', const = True)
#
# TODO: load filter param via argument parse somehow

args = parser.parse_args()
if args.debug:
  print('running debug mode')
  print('input file: "{}"'.format(args.inputfile))
  print('output file: "{}"'.format(args.outputfile))

if args.inputfile == None or args.outputfile == None:
  parser.print_help()
  exit(1)

if args.element_id == None:
  element_id ='42'
else:
  element_id = args.element_id

if args.element_tagname == None:
  element_tagname ='element'
else:
  element_tagname = args.element_tagname

if args.element_text == None:
  element_text ='some text'
else:
  element_text = args.element_text

# https://docs.python.org/2/library/xml.etree.elementtree.html
tree = ET.parse(args.inputfile)
root = tree.getroot()

user = ET.SubElement(root, element_tagname, id = element_id)
user.text = element_text
# NOTE: no need to appand the second time
# root.append(user)

tree.write(args.outputfile, encoding = 'UTF-8', xml_declaration = True)

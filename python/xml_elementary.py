#!/usr/bin/env python

from __future__ import print_function
import re
import time
from os import getenv, path
import sys 
import json, base64
from xml.dom import minidom

# https://docs.python.org/2/library/xml.dom.minidom.html
import re
# fragment of catalina web.xml modified to feature node attribute
data = """
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd" version="3.1">
  <filter>
    <filter-name>httpHeaderSecurity</filter-name>
    <filter-class>org.apache.catalina.filters.HttpHeaderSecurityFilter</filter-class>
    <async-supported setting="true"></async-supported>
  </filter>
</web-app>
"""
xmldoc = minidom.parseString(data.strip())
nodes = xmldoc.getElementsByTagName('filter')
for node in nodes:
  if re.match('httpHeader.*', node.getElementsByTagName('filter-name')[0].firstChild.data):
    print(node.getElementsByTagName('filter-class')[0].firstChild.data)
  if 'Security' in node.getElementsByTagName('filter-name')[0].firstChild.data:
    print(node.getElementsByTagName('async-supported')[0].attributes['setting'].value)


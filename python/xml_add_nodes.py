#!/usr/bin/env python

from __future__ import print_function
import re
import time
from os import getenv, path
import sys
import json, base64
from xml.dom import minidom
from xml.dom.minidom import getDOMImplementation

# https://docs.python.org/2/library/xml.dom.minidom.html
# https://stackoverflow.com/questions/10499534/xml-python-parsing-get-parent-node-name-minidom
def add_node(parent_document, parent_element, nodeData = None):
  if nodeData == None:
    impl = getDOMImplementation()
    newdoc = impl.createDocument(None, "some_tag", None)
    top_element = parent_document.documentElement
    child_node = newdoc.createTextNode('Some textual content.')
  else:
    child_node = minidom.parseString(nodeData).documentElement
  parent_element.appendChild(child_node)

# fragment of catalina web.xml modified to feature node attribute
data = """
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd" version="3.1">
  <filter>
    <filter-name>httpHeaderSecurity</filter-name>
    <filter-class>filters.HttpHeaderSecurityFilter</filter-class>
    <async-supported setting="true"></async-supported>
  </filter>
  <filter>
    <filter-name>someOtherFilter</filter-name>
    <filter-class>filters.HttpHeaderSecurityFilter</filter-class>
    <async-supported setting="true"></async-supported>
  </filter>
</web-app>
"""
xmldoc = minidom.parseString(re.sub(r'(\n+)', r' ',  data.strip()))
nodes = xmldoc.getElementsByTagName('filter')
for node in nodes:
  if re.match('httpHeader.*', node.getElementsByTagName('filter-name')[0].firstChild.data):
    print(node.getElementsByTagName('filter-class')[0].firstChild.data)
    # add_node(xmldoc, node.parentNode)
    add_node(xmldoc, node.parentNode, '<filter><filter-name>customFilter</filter-name><filter-class>example.filters.CustomFilter</filter-class><async-supported setting="true"></async-supported></filter>')
# some indent
print(xmldoc.toprettyxml())
# no indent
# xmldoc.writexml(sys.stdout)


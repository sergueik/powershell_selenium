#!/usr/bin/env python

# sudo -H pip3 install lxml --upgrade

from __future__ import print_function
import re
import time
from os import getenv, path
import sys
import json, base64
from xml.dom import minidom
from lxml import etree

import re
# fragment of nmap report
xml_data = """
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE nmaprun>
<nmaprun scanner="nmap" args="nmap -O -oX xml_data.xml 45.33.49.119" start="1602823938" startstr="Fri Oct 16 04:52:18 2020" version="7.80" xmloutputversion="1.04">
<scaninfo type="syn" protocol="tcp" numservices="1000" services="1,3-4"/>
<verbose level="0"/>
<debugging level="0"/>
<host starttime="1602823938" endtime="1602823972"><status state="up" reason="reset" reason_ttl="64"/>
<address addr="45.33.49.119" addrtype="ipv4"/>
<hostnames>
<hostname name="ack.nmap.org" type="PTR"/>
</hostnames>
<ports><extraports state="filtered" count="993">
<extrareasons reason="no-responses" count="993"/>
</extraports>
</ports>
<os><portused state="open" proto="tcp" portid="22"/>
<portused state="closed" proto="tcp" portid="70"/>
<osmatch name="HP P2000 G3 NAS device" accuracy="91" line="34647">
<osclass type="storage-misc" vendor="HP" osfamily="embedded" accuracy="91"><cpe>cpe:/h:hp:p2000_g3</cpe></osclass>
</osmatch>
<osmatch name="Linux 2.6.32" accuracy="90" line="55409">
<osclass type="general purpose" vendor="Linux" osfamily="Linux" osgen="2.6.X" accuracy="90"><cpe>cpe:/o:linux:linux_kernel:2.6.32</cpe></osclass>
</osmatch>
</os>
<uptime seconds="751775" lastboot="Wed Oct  7 12:03:18 2020"/>
<tcpsequence index="256" difficulty="Good luck!" values="5833A5A,D5206F79,8E66294D,8E3B0632,AC2DB44A,7F486476"/>
<ipidsequence class="All zeros" values="0,0,0,0,0,0"/>
<tcptssequence class="1000HZ" values="2CCF1F79,2CCF1FD4,2CCF2043,2CCF209E,2CCF2102,2CCF2164"/>
<times srtt="193340" rttvar="78390" to="506900"/>
</host>
<runstats><finished time="1602823973" timestr="Fri Oct 16 04:52:53 2020" elapsed="34.33" summary="Nmap done at Fri Oct 16 04:52:53 2020; 1 IP address (1 host up) scanned in 34.33 seconds" exit="success"/>
</runstats>
</nmaprun>
"""

xmldom = minidom.parseString(xml_data.strip())
nodes = xmldom.getElementsByTagName('cpe')
# for node in nodes:
#  print(node.firstChild.data)
print(nodes[0].firstChild.data)
nodes = xmldom.getElementsByTagName('address')
print (nodes[0].attributes['addr'].value)

lxml = etree.fromstring(xml_data.strip().encode(), parser = etree.XMLParser( encoding='utf-8', recover=True,))
address = lxml.xpath('//address/@addr')[0]
# NOTE:
# index inside xpath expression is relative
# the xpath method will still return an iterator with 2 elements:
cpe = lxml.xpath('//cpe[1]')[0]

print(f'{address} {cpe.text}')

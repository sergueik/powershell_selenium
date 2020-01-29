from __future__ import print_function
# https://stackoverflow.com/questions/5574702/how-to-print-to-stderr-in-python
from selenium import webdriver
import time
import traceback
import os
import sys
import locale

def debug_print(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def get_html(url):
    mobile_emulation = {'deviceName': 'Nexus 5'}
    user_agent = 'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0)'
    options = webdriver.ChromeOptions()
    options.add_argument( 'user-agent={}'.format(user_agent))
    # options.add_experimental_option('mobileEmulation', mobile_emulation)
    driver = webdriver.Chrome(options = options)
    driver.get(url)
    time.sleep(3)
    try:
        page_source = driver.page_source
        debug_print('read page source: {} bytes'.format( len(page_source)))
        # https://stackoverflow.com/questions/9942594/unicodeencodeerror-ascii-codec-cant-encode-character-u-xa0-in-position-20
        # UnicodeEncodeError: 'ascii' codec can't encode character u'\xa0' in position 4970: ordinal not in range(128)
        # page_source = page_source.encode('windows-1252', 'ignore').decode('windows-1252')
        # decoded_page_source = page_source.decode('windows-1252')
        # OK to lose some contents
        # page_source = page_source.encode('ascii', 'ignore').decode('ascii')
        # encoded_page_source = decoded_page_source.encode('utf8','ignore')
        encoded_page_source = page_source.encode('utf8','ignore')
        print(encoded_page_source)
    except Exception, e:
        print('Exception (ignored): {}'.format(e), file = sys.stderr)
        traceback.print_exc()
        pass
    finally:
      # NODE closing driver would hang the script
      # driver.close()
      print('quit driver', file = sys.stderr)
      driver.quit()

os.environ['PYTHONIOENCODING'] = 'utf-8'
url = 'https://www.tiktok.com/@egorkreed'
get_html(url)

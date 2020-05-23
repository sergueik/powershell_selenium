# # based on: https://groups.google.com/forum/#!topic/selenium-users/PuDpVblziAo
# the author author question is combination of

# see also: https://www.vionblog.com/selenium-headless-firefox-webdriver-using-pyvirtualdisplay/
# for full screen browser on dedicated X server
# proxy to deal with xfvb (optional , handy)
#!/usr/bin/env python

# no needs when headless
# from pyvirtualdisplay import Display

from selenium import webdriver
from selenium.webdriver.firefox.options import Options
from selenium.webdriver.firefox.firefox_binary import FirefoxBinary
import time, datetime, os
from os import getenv


# Set screen resolution to 1366 x 768 to emulate netbook / laptop

# display = Display(visible = 0, size = (1366, 768))
# display.start()

# now Firefox will run in a virtual display.
options = Options()
options.headless = True
binary = FirefoxBinary('/usr/bin/firefox')

# browser = webdriver.Firefox()
browser = webdriver.Firefox(firefox_binary = binary, executable_path = '{}/Downloads/geckodriver'.format(getenv('HOME')), options = options)

# Sets the width and height of the current window
browser.set_window_size(1366, 768)

# Open the URL
browser.get('http://www.wikipedia.org/')

# set timeouts
browser.set_script_timeout(30)
browser.set_page_load_timeout(30) # seconds

# Take screenshot
browser.save_screenshot('page.png')

# quit browser
browser.quit()

# quit Xvfb display
# display.stop()

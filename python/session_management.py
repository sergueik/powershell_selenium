# https://qna.habr.com/q/794275
import pickle
from selenium import webdriver
driver = webdriver.Firefox()
url = 'http://www.quora.com'
driver.get(url)
# login code
pickle.dump(driver.get_cookies(), open('cookies.pkl','wb'))
driver.close()
driver = webdriver.Firefox()
driver.get(url)
for cookie in pickle.load(open('cookies.pkl', 'rb')):
  driver.add_cookie(cookie)

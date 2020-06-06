# based on: https://qna.habr.com/q/786911
import clipboard

from selenium import webdriver
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as ec

driver = webdriver.Chrome()
# Загружаем страницу

driver.get("https://yandex.ru/chat/#/chats/1%2F0%2Fccb05ef5-1472-4e50-a926-602807a6ef94")
balloons_xpath = "//div[contains(@class, 'yamb-message-balloon')]"
WebDriverWait(driver, 10).until(ec.presence_of_all_elements_located((By.XPATH, balloons_xpath)))


# Выбираем посты в канале
balloons = driver.find_elements_by_xpath(balloons_xpath)

# Кликаем на пост #4
actionChains = ActionChains(driver)
actionChains.context_click(balloons[4]).perform()
get_link_text = 'Get message link'
driver.find_element_by_xpath(f"//span[text()='{get_link_text}']/..").click()

# Получаем буфер обмена
text = clipboard.paste()  # text will have the content of clipboard


print(text)
driver.quit()



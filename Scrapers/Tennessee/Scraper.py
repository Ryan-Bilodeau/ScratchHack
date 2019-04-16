from urllib.request import urlopen, Request
from bs4 import BeautifulSoup
from ScraperScope import *
from selenium import webdriver


url = 'https://www.tnlottery.com/games/instant-games/remaining-prizes'

options = webdriver.ChromeOptions()
options.add_argument('headless')

# driver = webdriver.Chrome(chrome_options=options,
#                           executable_path=Statics.windowsWebDriver)
driver = webdriver.Chrome(options=options,
                          executable_path=Statics.macWebDriver)
driver.get(url)
html = driver.page_source
soup = BeautifulSoup(html, 'html.parser')
temp = soup.find('table', {'class': 'cols-4 dataTable no-footer'}).find('tbody')

games = []

if not JobProperties.testing:
    DBManager.insertGamesAndPrizes(games)


from urllib.request import urlopen, Request
from bs4 import BeautifulSoup
from ScraperScope import *
from selenium import webdriver
import re


url = 'https://www.oregonlottery.org/games/scratch-its/compare'
print(url)
options = webdriver.ChromeOptions()
options.add_argument('headless')

# driver = webdriver.Chrome(chrome_options=options,
#                           executable_path=Statics .windowsWebDriver)
driver = webdriver.Chrome(options=options,
                          executable_path=Statics.macWebDriver)

driver.get(url)
button = driver.find_element_by_xpath("//select[@id='PageSize']")
button.click()
button.find_elements_by_tag_name("option")[0].click()

soup = BeautifulSoup(driver.page_source, 'html.parser')
rows = soup.find('table', {'id': 'compare-table'}).find('tbody').find_all('tr', recursive=False)

games = []
for row in rows:
    columns = row.find_all('td', recursive=False)

    try:
        int(Statics.formatNumber(columns[2].text))
    except IndexError:
        continue

    game = Game()

    game.state = "Oregon"
    game.name = Statics.formatName(columns[1].text)
    game.number = Statics.formatNumber(columns[6].text)
    game.price = Statics.formatNumber(columns[3].text)

    temp = row.find('tbody').find_all('tr')

    for p in temp:
        cols = p.find_all('td')

        try:
            int(Statics.formatNumber(cols[0].text))
        except IndexError:
            continue

        prize = Prize(game)
        prize.amount = Statics.formatNumber(cols[0].text)
        prize.prizesRemaining = Statics.formatNumber(cols[1].text)

    games.append(game)

games = Statics.formatGames(games)

if not JobProperties.testing:
    DBManager.insertGamesAndPrizes(games)
else:
    for game in games:
        game.printSelf()
        for p in game.prizes:
            p.printSelf()



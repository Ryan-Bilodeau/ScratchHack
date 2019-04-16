from urllib.request import urlopen, Request
from bs4 import BeautifulSoup
from ScraperScope import *
from selenium import webdriver
import re


def parsePage():
    print(link)
    driver.get(link)
    html = driver.page_source
    soup = BeautifulSoup(html, 'html.parser')
    game = Game()

    game.state = "New Jersey"
    temp = soup.find('div', {'class': 'instants-info'})
    game.name = Statics.formatName(temp.find('h2').text.split('-')[0])
    game.number = Statics.formatNumber(temp.find('p').text.split('#')[1])
    game.price = Statics.formatNumber(temp.find('h2').text.split('-')[1])
    temp = soup.find('div', {'class': 'gameSubTitleDescription text'}).find('p').text

    odds = re.findall(r'1 ticket in \d+|1 in \d+', temp)[0]
    odds = re.findall(r'\d+', odds)
    game.odds = odds[-1]

    temp = Statics.formatNumber(soup.find('time')['datetime']).split('/')
    game.startDate = f'{temp[2]}-{temp[0]}-{temp[1]}'

    table = soup.find('table', {'class', 'table--prizes-remain'}).find('tbody')
    rows = table.find_all('tr', recursive=False)
    for row in rows:
        columns = row.find_all('td')
        try:
            int(Statics.formatNumber(columns[0].text))
        except ValueError:
            continue

        prize = Prize(game)
        prize.amount = Statics.formatNumber(columns[0].text)
        prize.prizesPrinted = Statics.formatNumber(columns[1].text)
        prize.prizesRemaining = Statics.formatNumber(columns[2].text)

    return game


url = 'https://www.njlottery.com/en-us/scratch-offs/active.html#tab-active'
print(url)
options = webdriver.ChromeOptions()
options.add_argument('headless')

# driver = webdriver.Chrome(chrome_options=options,
#                           executable_path=Statics.windowsWebDriver)
driver = webdriver.Chrome(options=options,
                          executable_path=Statics.macWebDriver)
driver.get(url)
html = driver.page_source
soup = BeautifulSoup(html, 'html.parser')
temp = soup.find('div', {'id': 'instantsGames-ACTIVE'}).find_all('div', recursive=False)

games = []
links = []
for div in set(temp):
    link = div.find('a')['href'].split('/')
    link = 'https://www.njlottery.com/en-us/scratch-offs/' + link[len(link) - 1]
    links.append(link)

counter = 0
for link in links:
    try:
        games.append(parsePage())
    except AttributeError:
        games.append(parsePage())

    counter += 1

    if JobProperties.testing and counter == 2:
        break

games = Statics.formatGames(games)

if not JobProperties.testing:
    DBManager.insertGamesAndPrizes(games)
else:
    for game in games:
        game.printSelf()
        for p in game.prizes:
            p.printSelf()


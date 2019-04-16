from urllib.request import urlopen, Request
from bs4 import BeautifulSoup
from ScraperScope import *
from selenium import webdriver
import re


url = 'https://www.nmlottery.com/scratchers.aspx'
print(url)
options = webdriver.ChromeOptions()
options.add_argument('headless')

# driver = webdriver.Chrome(chrome_options=options,
#                           executable_path=Statics.windowsWebDriver)
driver = webdriver.Chrome(options=options,
                          executable_path=Statics.macWebDriver)

temp = []
# if loading page doesn't work the first time, try again once more
try:
    driver.get(url)
    html = driver.page_source
    soup = BeautifulSoup(html, 'html.parser')
    temp = soup.find('table', {'class': 'MDElementList MDclearBoth'}).find('tbody').find_all('tr', recursive=False)
except AttributeError:
    driver.get(url)
    html = driver.page_source
    soup = BeautifulSoup(html, 'html.parser')
    temp = soup.find('table', {'class': 'MDElementList MDclearBoth'}).find('tbody').find_all('tr', recursive=False)

games = []
for ticket in temp:
    if ticket.attrs['class'][0] != 'item':
        continue

    game = Game()

    temp = ticket.find_all('td', recursive=False)[1].find_all('div', recursive=False)

    game.state = 'New Mexico'

    temp[0].find('b').extract()
    name = Statics.formatName(temp[0].text)
    name = re.compile('\s*watch\s*the\s*video\s*', re.IGNORECASE).sub('', name)
    name = re.compile('\s*learn\s*how\s*to\s*play\s*', re.IGNORECASE).sub('', name)
    name = re.compile('\s*[-]+$').sub('', name)
    game.name = name

    temp[2].find('b').extract()
    game.price = Statics.formatNumber(temp[2].text)

    odds = temp[5].find('p').text.split(' in ')[1]
    game.odds = Statics.formatNumber(odds)

    temp[3].find('b').extract()
    date = Statics.formatNumber(temp[3].text)
    date = date.split(' ')
    game.startDate = f'{date[2]}-{Months.strMonthToNum(date[0])}-{date[1]}'

    p = temp[5].find('table').find('tbody').find_all('tr', recursive=False)[1]
    columns = p.find_all('td')
    prize = Prize(game)

    prize.amount = Statics.formatNumber(columns[0].text)
    prize.odds = Statics.formatNumber(columns[1].text)
    prize.prizesPrinted = Statics.formatNumber(columns[2].text)

    games.append(game)

games = Statics.formatGames(games)

if not JobProperties.testing:
    DBManager.insertGamesAndPrizes(games)
else:
    for game in games:
        game.printSelf()
        for p in game.prizes:
            p.printSelf()


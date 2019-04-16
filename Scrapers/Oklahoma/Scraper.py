from urllib.request import urlopen, Request
from bs4 import BeautifulSoup
from ScraperScope import *
from selenium import webdriver
import re


urls = ['https://www.lottery.ok.gov/scratchers.asp?priceRange=$1',
        'https://www.lottery.ok.gov/scratchers.asp?priceRange=$2',
        'https://www.lottery.ok.gov/scratchers.asp?priceRange=$3',
        'https://www.lottery.ok.gov/scratchers.asp?priceRange=$5',
        'https://www.lottery.ok.gov/scratchers.asp?priceRange=$10']

remainingPrizesUrl = 'https://www.lottery.ok.gov/remaining_prizes.asp'

options = webdriver.ChromeOptions()
options.add_argument('headless')

# driver = webdriver.Chrome(chrome_options=options,
#                           executable_path=Statics.windowsWebDriver)
driver = webdriver.Chrome(options=options,
                          executable_path=Statics.macWebDriver)

print(remainingPrizesUrl)
driver.get(remainingPrizesUrl)
soup = BeautifulSoup(driver.page_source, 'html.parser')
temp = soup.find('div', {'class': 'large-12 medium-12 columns'})

games = []
gameCounter = 0
for title in temp.find_all('h3'):
    game = Game()

    game.state = 'Oklahoma'
    game.name = Statics.formatName(title.text.split('#')[0])
    game.number = Statics.formatNumber(title.text.split('#')[1])

    table = temp.find_all('tbody')[gameCounter]
    for row in table.find_all('tr', recursive=False):
        columns = row.find_all('td', recursive=False)
        try:
            int(Statics.formatNumber(columns[1].text))
        except (ValueError, IndexError):
            continue

        prize = Prize(game)

        prize.amount = Statics.formatNumber(columns[0].text)
        prize.prizesPrinted = Statics.formatNumber(columns[2].text)
        prize.prizesRemaining = Statics.formatNumber(columns[1].text)

    games.append(game)
    gameCounter += 1

links = []
for link in urls:
    print(link)
    driver.get(link)
    soup = BeautifulSoup(driver.page_source, 'html.parser')
    tbl = soup.find('div', {'class': 'large-12 medium-12 columns'}).find('tbody')

    for a in tbl.find_all('a'):
        links.append('https://www.lottery.ok.gov/' + a['href'])

    if JobProperties.testing:
        break

counter = 0
for link in links:
    print(link)
    driver.get(link)
    soup = BeautifulSoup(driver.page_source, 'html.parser')

    temp = soup.find_all('div', {'class': 'six large-6 medium-6 columns'})[1].find_all('div')[1]
    rows = temp.find_all('p')

    for row in rows:
        row.find('b').extract()

    number = Statics.formatNumber(rows[4].text)
    for game in games:
        if game.number == number:
            game.price = Statics.formatNumber(rows[0].text)
            temp = rows[2].text.lower().split('in')[1]
            game.odds = Statics.formatNumber(temp)
            temp = Statics.formatNumber(rows[1].text).split('/')
            game.startDate = f'{temp[2]}-{temp[0]}-{temp[1]}'

    counter += 1
    if JobProperties.testing and counter == 2:
        break

finalGames = []
for game in games:
    try:
        int(game.price)
        finalGames.append(game)
    except ValueError:
        pass

games = Statics.formatGames(finalGames)

if not JobProperties.testing:
    DBManager.insertGamesAndPrizes(games)
else:
    for game in games:
        game.printSelf()
        for p in game.prizes:
            p.printSelf()


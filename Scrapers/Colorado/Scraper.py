from urllib.request import urlopen
from bs4 import BeautifulSoup
from ScraperScope import *
import operator

url = 'https://www.coloradolottery.com/en/player-tools/scratch-insider/?'
print(url)
page = urlopen(url)
soup = BeautifulSoup(page, 'html.parser')
games = []

t = soup.find('div', attrs={'class': 'tableWrap'}).find('tbody')
rows = t.find_all('tr', recursive=False)
counter = 0
for row in rows:
    game = Game()
    columns = row.find_all('td', recursive=False)

    game.state = "Colorado"
    game.name = Statics.formatName(columns[0].find('span').text)
    game.number = Statics.formatNumber(columns[1].text)
    game.price = Statics.formatNumber(columns[2].text)
    game.odds = Statics.formatNumber(columns[8].text.strip().split('in')[1])
    game.startDate = columns[3].find('time').get('datetime')

    prize = Prize(game)
    prize.amount = Statics.formatNumber(columns[5].text)
    prize.prizesPrinted = Statics.formatNumber(columns[6].text)
    prize.prizesRemaining = Statics.formatNumber(columns[7].text)

    link = columns[0].find('a')['href']
    print(link)
    page = urlopen(link)
    soup = BeautifulSoup(page, 'html.parser')

    temp = soup.find('table', attrs={'class': 'respond'}).find('tbody').find('tr')
    prize.odds = Statics.formatNumber(temp.find_all('td')[2].text.split('in')[1])

    games.append(game)

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

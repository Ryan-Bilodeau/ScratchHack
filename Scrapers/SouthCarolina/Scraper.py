from urllib.request import urlopen
from bs4 import BeautifulSoup
from ScraperScope import *

url = 'http://www.sceducationlottery.com/instant_games/games.aspx'
print(url)
page = urlopen(url)
soup = BeautifulSoup(page, 'html.parser')
temp = soup.find('table', {'id': 'dlGames'}).find_all('div', {'style': 'display:block; min-height:40px;'})

games = []
counter = 0
for card in temp:
    link = 'http://www.sceducationlottery.com/instant_games/' + card.find('a')['href']
    print(link)
    game = Game()

    game.state = 'South Carolina'
    game.name = Statics.formatName(card.find('a').find_all('span', recursive=False)[0].text)
    game.number = Statics.formatNumber(card.find('a').find_all('span', recursive=False)[1].text)

    soup = BeautifulSoup(urlopen(link), 'html.parser')

    game.price = Statics.formatNumber(soup.find('span', {'id': 'price'}).text)
    game.odds = Statics.formatNumber(soup.find('span', {'id': 'overallOdds'}).text)
    temp = Statics.formatNumber(soup.find('span', {'id': 'start'}).text).split('/')
    game.startDate = f'{temp[2]}-{temp[0]}-{temp[1]}'

    rows = soup.find('table', {'class': 'prizes'}).find_all('tr', recursive=False)
    rows.remove(rows[0])
    for row in rows:
        columns = row.find_all('td', recursive=False)

        prize = Prize(game)
        prize.amount = Statics.formatNumber(columns[0].text)
        prize.prizesPrinted = Statics.formatNumber(columns[3].text)
        prize.prizesRemaining = Statics.formatNumber(columns[1].text)

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


from urllib.request import urlopen
from bs4 import BeautifulSoup
from ScraperScope import *

url = 'https://louisianalottery.com/scratch-offs/top-prizes-remaining'
print(url)
page = urlopen(url)
soup = BeautifulSoup(page, 'html.parser')
rows = soup.find('table', attrs={'class': 'table table-condensed table-bordered table-striped table-data'})
rows = rows.find('tbody').find_all('tr', recursive=False)

games = []
counter = 0
for row in rows:
    url = row.find('a')['href']
    print(url)
    page = urlopen(url)
    soup = BeautifulSoup(page, 'html.parser')

    game = Game()

    game.state = "Louisiana"
    game.name = Statics.formatName(soup.find('span', attrs={'class': 'scratch-off-title'}).text)
    game.number = Statics.formatName(
        soup.find('span', attrs={'class': 'scratch-off-number'}).text.split(' ')[-1])

    tables = soup.find_all('table', attrs={'class': 'table-condensed'})
    rows = tables[0].find_all('tr')

    game.price = Statics.formatNumber(rows[0].find_all('td')[1].text)
    game.odds = Statics.formatNumber(rows[2].find_all('td')[1].text.split('in')[1])
    temp = Statics.formatNumber(tables[1].find_all('td')[1].text).split('/')
    game.startDate = f'20{temp[2]}-{temp[0]}-{temp[1]}'
    game.percentSold = Statics.formatNumber(rows[4].find_all('td')[1].text)

    try:
        float(game.percentSold)
    except ValueError:
        continue

    prizes = soup.find('table', attrs={'class': 'table table-striped data-table table-tier'})
    prizes = prizes.find('tbody').find_all('tr')
    prizes.remove(prizes[len(prizes) - 1])
    for p in prizes:
        prize = Prize(game)
        columns = p.find_all('td')

        prize.amount = Statics.formatNumber(columns[0].text)
        prize.odds = Statics.formatNumber(columns[1].text.split('in')[1])
        prize.prizesPrinted = Statics.formatNumber(columns[2].text)
        prize.prizesRemaining = Statics.formatNumber(columns[4].text)

    games.append(game)

    counter += 1
    if JobProperties.testing and counter == 2:
        for game in games:
            game.printSelf()
            for p in game.prizes:
                p.printSelf()
        break

games = Statics.formatGames(games)

if not JobProperties.testing:
    DBManager.insertGamesAndPrizes(games)
else:
    for game in games:
        game.printSelf()
        for p in game.prizes:
            p.printSelf()


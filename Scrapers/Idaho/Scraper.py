from urllib.request import urlopen
from bs4 import BeautifulSoup
from ScraperScope import *

url = 'https://www.idaholottery.com/games/scratch'
print(url)
page = urlopen(url)
soup = BeautifulSoup(page, 'html.parser')
cards = soup.find('ul', attrs={'class': 'games'}).find_all('li')

games = []
counter = 0
for card in cards:
    url = "https://www.idaholottery.com" + card.find('a')['href']
    print(url)
    page = urlopen(url)
    soup = BeautifulSoup(page, 'html.parser')

    game = Game()

    game.state = "Idaho"
    game.name = Statics.formatName(soup.find('a', attrs={'class': 'show--shell'}).find('h5').text)
    game.number = card['data-game-id']

    temp = soup.find('ul', attrs={'class': 'list-badgets'}).find_all('li')

    game.price = Statics.formatNumber(temp[1].find('h4').text)
    odds = Statics.formatNumber(temp[2].find('h4').text)

    try:
        odds = odds.split(':')[1]
    except IndexError:
        pass

    game.odds = odds
    game.percentSold = Statics.formatNumber(temp[3].find('h4').text)

    temp = soup.find('table', attrs={'class': 'full-rules-and-odds prize-chart-table'}).find('tbody')
    temp = temp.find_all('tr', recursive=False)

    for row in temp:
        columns = row.find_all('td')

        remaining = ''
        try:
            remaining = int(Statics.formatNumber(columns[2].text))
        except ValueError:
            continue

        printed = ''
        try:
            printed = int(Statics.formatNumber(columns[0].text))
        except ValueError:
            continue

        odds = Statics.formatNumber(columns[3].text)
        try:
            odds = odds.split(':')[1]
        except IndexError:
            pass

        prize = Prize(game)

        prize.amount = Statics.formatNumber(columns[1].text)
        prize.prizesPrinted = printed
        prize.prizesRemaining = remaining
        prize.odds = odds

    if len(game.prizes) > 0:
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


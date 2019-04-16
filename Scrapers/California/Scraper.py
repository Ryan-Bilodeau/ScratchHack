from urllib.request import urlopen
from bs4 import BeautifulSoup
from ScraperScope import *

url = 'http://www.calottery.com/play/scratchers-games/top-prizes-remaining'
print(url)
page = urlopen(url)
soup = BeautifulSoup(page, 'html.parser')

t = soup.find('div', attrs={'id': 'main-column'}).find('h1', recursive=False).text

table = soup.find('table', attrs={'id': 'topprizetable'})
links = set(table.find_all('a'))

games = []
counter = 0
for a in links:
    link = 'https://www.calottery.com/' + a['href']
    print(link)
    page = urlopen(link)
    soup = BeautifulSoup(page, 'html.parser')

    game = Game()

    game.state = "California"
    game.name = soup.find('div', attrs={'class': 'heroContentBox'}).find('h1').text
    game.name = Statics.formatName(game.name)

    data = soup.find('p', attrs={'class': 'scratchers-full-width'}).text
    game.number = Statics.formatNumber(data.split('Game Number: ')[1])
    game.price = Statics.formatNumber(data.split('$')[1].split('|')[0])
    game.odds = Statics.formatNumber(data.split('in ')[1].split('|')[0])

    prizes = []

    prizeTable = soup.find('table', attrs={'class': 'draw_games tag_even'}).find('tbody')
    rows = prizeTable.find_all('tr')
    rows.remove(rows[len(rows) - 1])

    for row in rows:
        prize = Prize(game)
        columns = row.find_all('td')

        prize.amount = Statics.formatNumber(columns[0].text)
        prize.odds = Statics.formatNumber(columns[1].text)
        prize.prizesPrinted = Statics.formatNumber(columns[2].text)
        prize.prizesRemaining = Statics.formatNumber(columns[4].text)

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




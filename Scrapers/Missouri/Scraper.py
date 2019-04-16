from urllib.request import urlopen
from bs4 import BeautifulSoup
from ScraperScope import *
import re

url = 'http://www.molottery.com/scratchers.do'
print(url)
page = urlopen(url)
soup = BeautifulSoup(page, 'html.parser')
rows = soup.find('table', attrs={'class': 'scratchers-table table-desc'})
rows.find('thead').extract()
rows = rows.find_all('tr', recursive=False)

games = []
links = []
for i in range(0, len(rows), 4):
    temp = rows[i+1].find_all('td')[1]
    temp.find('b').extract()
    temp = temp.text.strip()
    if temp > Statics.getCurrentDate():
        link = "http://www.molottery.com" + rows[i].find_all('td')[2].find('a')['href']
        links.append(link)

counter = 0
for link in links:
    print(link)
    soup = BeautifulSoup(urlopen(link), 'html.parser')
    game = Game()

    temp = soup.find('div', attrs={'class': 'content-box'})
    title = temp.find('h1')

    try:
        title.find('sup').extract()
    except AttributeError:
        pass

    title = title.text

    game.state = "Missouri"
    game.name = Statics.formatName(title.split('-')[title.count('-') - 1])
    game.number = Statics.formatNumber(title.split('#')[1])
    game.price = Statics.formatNumber(temp.find('dl').find('dd').text)
    odds = soup.find_all('dl', recursive=False)[2].find('dd').text
    game.odds = Statics.formatNumber(odds.split('in')[1])
    game.startDate = Statics.formatNumber(temp.find_all('dl')[1].find('dd').text).split(' ')[0]
    money = soup.find_all('div', attrs={'align': 'center'})[1].find('b').text.split(':')[1]
    game.totalMoneyUnclaimed = Statics.formatNumber(money)

    p = soup.text
    p = re.compile(r',').sub('', p)
    p = re.compile(r'\s+').sub(' ', p)
    rows = re.findall(r'\$\d+ \d+ \d+', p)

    for row in rows:
        columns = row.split(' ')
        prize = Prize(game)
        prize.amount = Statics.formatNumber(columns[0])
        prize.prizesPrinted = Statics.formatNumber(columns[1])
        prize.prizesRemaining = Statics.formatNumber(columns[2])

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



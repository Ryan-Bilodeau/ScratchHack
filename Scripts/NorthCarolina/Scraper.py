from urllib.request import urlopen
from bs4 import BeautifulSoup
from ScraperScope import *

url = 'https://www.nclottery.com/ScratchOff?gt=0'
print(url)
page = urlopen(url)
soup = BeautifulSoup(page, 'html.parser')
temp = soup.find_all('div', {'class': 'box-group'})[1].find_all('a')

games = []
links = []
counter = 0
for a in temp:
    link = 'https://www.nclottery.com/' + a['href']
    print(link)
    soup = BeautifulSoup(urlopen(link), 'html.parser')
    game = Game()
    tables = ""

    if len(soup.find_all('div', {'class': 'TicketData'})) > 0:
        tables = soup.find_all('div', {'class': 'TicketData'})
    else:
        continue
        
    rows = tables[0].find('tbody').find_all('tr', recursive=False)

    game.state = "North Carolina"
    game.name = Statics.formatName(soup.find_all('span', {'class': 'icon-svg-star'})[1].parent.text)
    game.number = Statics.formatNumber(rows[4].find_all('td')[1].text)

    game.price = Statics.formatNumber(rows[0].find_all('td')[1].text)
    game.odds = Statics.formatNumber(rows[2].find_all('td')[1].text.split('in')[1])
    date = Statics.formatNumber(rows[3].find_all('td')[1].text).split(' ')
    game.startDate = f'{date[2]}-{Months.strMonthToNum(date[0])}-{date[1]}'
    
    rows = tables[1].find('tbody').find_all('tr', recursive=False)
    for row in rows:
        prize = Prize(game)
        columns = row.find_all('td')

        prize.amount = Statics.formatNumber(columns[0].find('span').text)
        prize.prizesPrinted = Statics.formatNumber(columns[1].find('span').text)
        prize.prizesRemaining = Statics.formatNumber(columns[2].find('span').text)

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


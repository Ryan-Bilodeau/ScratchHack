from urllib.request import urlopen
from bs4 import BeautifulSoup
from ScraperScope import *

remainingPrizesLink = 'http://www.mainelottery.com/players_info/unclaimed_prizes.html'
gameLinks = ['http://www.mainelottery.com/instant/scratch1dollar.html',
             'http://www.mainelottery.com/instant/scratch2dollar.html',
             'http://www.mainelottery.com/instant/scratch3dollar.html',
             'http://www.mainelottery.com/instant/scratch5dollar.html',
             'http://www.mainelottery.com/instant/scratch10dollar.html',
             'http://www.mainelottery.com/instant/scratch20dollar.html',
             'http://www.mainelottery.com/instant/scratch25dollar.html']

games = []
counter = 0
for page in gameLinks:
    soup = BeautifulSoup(urlopen(page), 'html.parser')
    links = soup.find('div', attrs={'id': 'maincontent1'}).find_all('div', recursive=False)

    if len(links) == 1:
        links = links[0].find_all('div', recursive=False)

    for link in links:
        game = Game()
        print(link.find('a')['href'])
        soup = BeautifulSoup(urlopen(link.find('a')['href']), 'html.parser')
        content = soup.find('div', attrs={'id': 'maincontent1'})

        game.state = 'Maine'
        game.name = Statics.formatName(content.find('h1').text)
        temp = content.find_all('strong')
        temp = temp[len(temp) - 1].text.split(':')[1].split(' ')[0]
        game.odds = Statics.formatNumber(temp)
        temp = content.find_all('p')[len(content.find_all('p')) - 2].text.split(' ')
        year = temp[len(temp) - 1]
        month = Months.getMonthNum(temp[len(temp) - 3])
        day = temp[len(temp) - 2].replace(',', '')
        temp = f"{year}-{month}-{day}"
        game.startDate = Statics.formatNumber(temp)

        game.ticketsPrinted = Statics.formatNumber(content.find_all('p')[-1].text.strip().split(' ')[-1])
        games.append(game)

        counter += 1
        if JobProperties.testing and counter >= 1:
            break

print(remainingPrizesLink)
soup = BeautifulSoup(urlopen(remainingPrizesLink), 'html.parser')
table = soup.find('table', attrs={'class': 'tbstriped'})
rows = table.find_all('tr')
rows.remove(rows[0])

for row in rows:
    columns = row.find_all('td')

    try:
        int(Statics.formatNumber(columns[1].text))
    except ValueError:
        continue

    for g in games:
        if g.name.upper() == Statics.formatName(columns[2].text).upper():
            g.price = Statics.formatNumber(columns[0].text)
            g.number = Statics.formatNumber(columns[1].text)
            g.percentSold = 100.0 - float(Statics.formatNumber(columns[3].text))
            g.totalMoneyUnclaimed = Statics.formatNumber(columns[4].text)

            if len(g.prizes) > 0:
                g.prizes.remove(g.prizes[0])

            prize = Prize(g)
            prize.amount = Statics.formatNumber(columns[5].text)
            prize.prizesRemaining = Statics.formatNumber(columns[6].text)

games = Statics.formatGames(games)

for game in games:
    if game.number == 'NULL':
        games.remove(game)

if not JobProperties.testing:
    DBManager.insertGamesAndPrizes(games)
else:
    for game in games:
        game.printSelf()
        for p in game.prizes:
            p.printSelf()

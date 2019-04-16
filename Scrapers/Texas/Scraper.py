from urllib.request import urlopen
from bs4 import BeautifulSoup
from ScraperScope import *

url = 'https://www.txlottery.org/export/sites/lottery/Games/Scratch_Offs/all.html'
print(url)
page = urlopen(url)
soup = BeautifulSoup(page, 'html.parser')
temp = soup.find('div', {'class': 'large-9 columns'}).find('table', recursive=False)
rows = temp.find('tbody').find_all('tr', recursive=False)

games = []
links = []
for row in rows:
    game = Game()
    columns = row.find_all('td', recursive=False)

    try:
        int(Statics.formatNumber(columns[0].text))
    except ValueError:
        continue

    link = 'https://www.txlottery.org' + columns[0].find('a')['href']
    links.append(link)

    game.state = "Texas"
    game.name = Statics.formatName(columns[4].text)
    game.number = Statics.formatNumber(columns[0].find('a').text)
    game.price = Statics.formatNumber(columns[2].text)
    temp = Statics.formatNumber(columns[1].text).split('/')
    game.startDate = f'20{temp[2]}-{temp[0]}-{temp[1]}'

    games.append(game)

counter = 0
for link in links:
    print(link)
    page = urlopen(link)
    soup = BeautifulSoup(page, 'html.parser')

    temp = soup.find_all('div', {'class': 'large-12 columns'})[3].find('h3').text
    number = Statics.formatNumber(temp.split(' ')[2])
    name = Statics.formatName(temp.split('-')[1])

    for game in games:
        if game.name == name and game.number == number:
            temp = soup.find('p', {'class': 'scratchoffDetailsOdds'}).text
            temp = temp.split('**')[0].split(' ')
            game.odds = Statics.formatNumber(temp[len(temp) - 1])

            temp = soup.find('table', {'class': 'large-only'})
            rows = temp.find('tbody').find_all('tr', recursive=False)

            for row in rows:
                columns = row.find_all('td', recursive=False)
                try:
                    int(Statics.formatNumber(columns[2].text))
                except ValueError:
                    break

                prize = Prize(game)

                prize.amount = Statics.formatNumber(columns[0].text)

                if prize.amount.count('wk') > 0:
                    prize.amount = float(prize.amount.split('/')[0]) * 52

                prize.prizesPrinted = Statics.formatNumber(columns[1].text)
                prize.prizesRemaining = Statics.formatNumber(columns[2].text)

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


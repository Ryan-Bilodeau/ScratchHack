from urllib.request import urlopen
from bs4 import BeautifulSoup
from ScraperScope import *

url = 'https://nelottery.com/homeapp/scratch/prizesremaining/web'
print(url)
page = urlopen(url)
soup = BeautifulSoup(page, 'html.parser')
rows = soup.find_all('div', attrs={'class': 'gameBlock'})

games = []
links = []
for row in rows:
    game = Game()
    divs = row.find_all('div', recursive=False)

    game.state = "Nebraska"
    game.name = Statics.formatName(divs[1].find_all('span', recursive=False)[1].text)
    temp = divs[1].find('span')
    game.number = Statics.formatNumber(temp.text)
    game.price = Statics.formatNumber(divs[0].find('span').find_all('span')[1].text)

    link = divs[2].find('a')['href']
    links.append(link)

    p = divs[3].find_all('span', {'class': 'prizeDescriptionBlock'})
    r = divs[3].find_all('span', {'class': 'prizeCountBlock'})

    for i in range(0, len(p)):
        try:
            num = p[i].text.replace('$', '')
            int(num.replace(',', ''))
        except ValueError:
            continue

        prize = Prize(game)
        prize.amount = Statics.formatNumber(p[i].text)
        prize.prizesRemaining = Statics.formatNumber(r[i].text)

    games.append(game)

counter = 0
for link in links:
    print(link)
    soup = BeautifulSoup(urlopen(link), 'html.parser')
    number = soup.find('h2', {'class': 'mobileTitle'}).text
    number = number.split('-')[0]
    number = Statics.formatNumber(number)
    odds = soup.find_all('div', {'class': 'textBlock'})[1].text
    odds = Statics.formatNumber(odds.split('in')[1])

    for game in games:
        if game.number == number:
            game.odds = odds

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




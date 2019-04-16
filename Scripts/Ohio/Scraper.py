from urllib.request import urlopen
from bs4 import BeautifulSoup
from ScraperScope import *

urls = ['https://www.ohiolottery.com/Games/InstantGames/$30-Games',
        'https://www.ohiolottery.com/Games/InstantGames/20DollarGames',
        'https://www.ohiolottery.com/Games/InstantGames/10DollarGames',
        'https://www.ohiolottery.com/Games/InstantGames/$5-Games',
        'https://www.ohiolottery.com/Games/InstantGames/$3-Games',
        'https://www.ohiolottery.com/Games/InstantGames/$2-Games',
        'https://www.ohiolottery.com/Games/InstantGames/$1-Games']

links = []
for url in urls:
    print(url)
    page = urlopen(url)
    soup = BeautifulSoup(page, 'html.parser')
    temp = soup.find('ul', {'class': 'igLandingList clearfix'}).find_all('li', recursive=False)

    for l in temp:
        link = "https://www.ohiolottery.com/" + l.find('a')['href']
        links.append(link)

games = []
counter = 0
for link in links:
    print(link)
    game = Game()
    page = urlopen(link)
    soup = BeautifulSoup(page, 'html.parser')

    game.state = "Ohio"
    game.name = Statics.formatName(soup.find('div', {'class': 'page_content cf'}).find('h1').text)
    game.number = Statics.formatNumber(soup.find('span', {'class': 'number'}).text)

    if 'D' in link.split('/')[-2]:
        game.price = Statics.formatNumber(link.split('/')[-2].split('D')[0])
    else:
        game.price = Statics.formatNumber(link.split('/')[-2].split('-')[0])

    if len(soup.find('p', {'class': 'odds'}).text.lower().split(' in ')) == 1:
        continue
    else:
        game.odds = soup.find('p', {'class': 'odds'}).text.lower().split(' in ')[1]

    temp = soup.find('div', {'class': 'tbl_PrizesRemaining'}).find('tbody').find_all('tr', recursive=False)
    temp.remove(temp[0])
    temp.remove(temp[0])

    for row in temp:
        columns = row.find_all('td', recursive=False)
        try:
            float(Statics.formatNumber(columns[0].text))
        except ValueError:
            continue

        prize = Prize(game)
        prize.amount = Statics.formatNumber(columns[0].text)
        prize.prizesRemaining = Statics.formatNumber(columns[1].text)

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




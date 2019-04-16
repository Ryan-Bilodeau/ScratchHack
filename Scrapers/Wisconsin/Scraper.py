from urllib.request import urlopen
from bs4 import BeautifulSoup
from ScraperScope import *
from operator import attrgetter

url = 'https://www.wilottery.com/scratchgames/index.aspx'
print(url)
page = urlopen(url)
soup = BeautifulSoup(page, 'html.parser')
temp = soup.find('div', {'id': 'accordiontickets'}).find_all('a')

games = []
counter = 0
for a in temp:
    if 'hist' in a['href']:
        continue

    link = "https://www.wilottery.com" + a['href']
    print(link)
    page = urlopen(link)
    soup = BeautifulSoup(page, 'html.parser')
    game = Game()

    game.state = "Wisconsin"
    game.name = Statics.formatName(
        soup.find('span', {'id': 'ctl00_ContentPlaceHolder1_DetailBox_lblName'}).text)
    game.number = Statics.formatNumber(
        soup.find('span', {'id': 'ctl00_ContentPlaceHolder1_DetailBox_lblNum'}).text)
    game.price = Statics.formatNumber(
        soup.find('span', {'id': 'ctl00_ContentPlaceHolder1_DetailBox_lblPrice'}).text)
    game.odds = Statics.formatNumber(
        soup.find('span', {'id': 'ctl00_ContentPlaceHolder1_DetailBox_lblOddsOverall'}).text.split(':')[1])
    temp = Statics.formatNumber(
        soup.find('span', {'id': 'ctl00_ContentPlaceHolder1_DetailBox_lblStart'}).text).split('/')

    try:
        game.startDate = f'{temp[2]}-{temp[0]}-{temp[1]}'
    except IndexError:
        continue

    prizes = soup.find('span', {'id': 'ctl00_ContentPlaceHolder1_DetailBox_lblOdds'})
    prizes = prizes.find('p').text.split('$')

    for prize in prizes:
        if ':' not in prize:
            continue

        p = Prize(game)
        p.amount = Statics.formatNumber(prize.split(' ')[0])
        p.odds = Statics.formatNumber(prize.split(':')[1])

    game.prizes.sort(key=attrgetter('amountAsInt'), reverse=False)

    if len(game.prizes) > 0:
        game.prizes[-1].prizesPrinted = Statics.formatNumber(
            soup.find('span', {'id': 'ctl00_ContentPlaceHolder1_DetailBox_LblTopPrize'}).text)
        game.prizes[-1].prizesRemaining = Statics.formatNumber(
            soup.find('span', {'id': 'ctl00_ContentPlaceHolder1_DetailBox_lblRemaining'}).text)

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


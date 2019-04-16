import datetime
import html
import mysql.connector
import re


class JobProperties:
    testing = False


class Game:
    def __init__(self):
        self.state = 'NULL'
        self.name = 'NULL'
        self.number = 'NULL'
        self.price = 'NULL'
        self.odds = 'NULL'
        self.startDate = 'NULL'
        self.percentSold = 'NULL'
        self.totalMoneyUnclaimed = 'NULL'
        self.ticketsPrinted = 'NULL'

        self.prizes = []
        self.scrapeDate = Statics.getCurrentDate()

    def getPrimaryKey(self):
        key = f'{self.scrapeDate}_{self.number}_{self.startDate}_{self.state}_{self.name}'
        return key

    def printSelf(self):
        output = f'Name: {self.name}, '
        output += f'Number: {self.number}, '
        output += f'Price: {self.price}, '
        output += f'Odds: {self.odds}, '
        output += f'StartDate: {self.startDate}, '
        output += f'PercentSold: {self.percentSold}, '
        output += f'TotalUnclaimed: {self.totalMoneyUnclaimed}, '
        output += f'NumberOfPrizes: {len(self.prizes)}'
        print(output)

    def getSQLName(self):
        if self.name == 'NULL':
            return self.name
        else:
            return f"'{self.name}'"

    def getSQLNumber(self):
        if self.number == 'NULL':
            return self.number
        else:
            try:
                return f"'{int(self.number)}'"
            except ValueError:
                self.printSelf()
                raise

    def getSQLPrice(self):
        if self.price == 'NULL':
            return self.price
        else:
            try:
                return f"'{float(self.price)}'"
            except ValueError:
                self.printSelf()
                raise

    def getSQLOdds(self):
        if self.odds == 'NULL':
            return self.odds
        else:
            try:
                return f"'{float(self.odds)}'"
            except ValueError:
                self.printSelf()
                raise

    def getSQLStartDate(self):
        if self.startDate == 'NULL':
            return self.startDate
        else:
            return f"'{self.startDate}'"

    def getSQLPercentSold(self):
        if self.percentSold == 'NULL':
            return self.percentSold
        else:
            try:
                return f"'{float(self.percentSold)}'"
            except ValueError:
                self.printSelf()
                raise

    def getSQLTotalUnclaimed(self):
        if self.totalMoneyUnclaimed == 'NULL':
            return self.totalMoneyUnclaimed
        else:
            try:
                return f"'{float(self.totalMoneyUnclaimed)}'"
            except ValueError:
                self.printSelf()
                raise

    def getSQLTicketsPrinted(self):
        if self.ticketsPrinted == 'NULL':
            return self.ticketsPrinted
        else:
            return f"'{self.ticketsPrinted}'"


class Prize:
    def __init__(self, game: Game):
        game.prizes.append(self)

        self.amount = 'NULL'
        self.odds = 'NULL'
        self.prizesPrinted = 'NULL'
        self.prizesRemaining = 'NULL'

        self.game = game
        self.scrapeDate = Statics.getCurrentDate()

    @property
    def amountAsInt(self):
        try:
            return int(self.amount)
        except ValueError:
            self.printSelf()
            raise

    def getPrimaryKey(self):
        key = f'{self.getForeignKey()}_{self.amount}'
        return key

    def getForeignKey(self):
        return self.game.getPrimaryKey()

    def printSelf(self):
        output = f'Amount: {self.amount}, '
        output += f'Odds: {self.odds}, '
        output += f'PrizesPrinted: {self.prizesPrinted}, '
        output += f'PrizesRemaining: {self.prizesRemaining}'
        print(output)

    def getSQLAmount(self):
        if self.amount == 'NULL':
            return self.amount
        else:
            try:
                return f"'{float(self.amount)}'"
            except ValueError:
                self.printSelf()
                raise

    def getSQLOdds(self):
        if self.odds == 'NULL':
            return self.odds
        else:
            try:
                return f"'{float(self.odds)}'"
            except ValueError:
                self.printSelf()
                raise

    def getSQLPrizesPrinted(self):
        if self.prizesPrinted == 'NULL':
            return self.prizesPrinted
        else:
            try:
                return f"'{int(self.prizesPrinted)}'"
            except ValueError:
                self.printSelf()
                raise

    def getSQLPrizesRemaining(self):
        if self.prizesRemaining == 'NULL':
            return self.prizesRemaining
        else:
            try:
                return f"'{int(self.prizesRemaining)}'"
            except ValueError:
                self.printSelf()
                raise


class Statics:
    @staticmethod
    def getCurrentDate():
        time = datetime.datetime.now()
        year = time.year
        month = time.month
        if month < 10:
            month = "0" + str(time.month)
        day = time.day
        if day < 10:
            day = "0" + str(time.day)
        return f'{year}-{month}-{day}'

    @staticmethod
    def formatGames(games):
        gs = []

        for game in games:
            # if len([g for g in games if game.getPrimaryKey() == g.getPrimaryKey()]) < 2:
            if game.getPrimaryKey() not in [x.getPrimaryKey() for x in gs]:
                gs.append(game)

        return gs

    @staticmethod
    def formatName(name):
        temp = html.unescape(name)
        temp = temp.replace('\'', '\'\'')
        # temp = temp.replace('"', '')
        # temp = temp.replace('â', '')
        # temp = temp.replace('¢', '')
        # temp = temp.replace('™', '')
        # temp = temp.replace('®', '')
        # temp = temp.replace('  ', '')
        # temp = temp.replace('   ', '')
        # temp = temp.replace('\t', '')
        # temp = temp.strip()

        temp = re.compile(r'[^\w\s\'!#$&,?%\-]').sub('', temp)
        # print(1, temp)
        temp = re.compile(r'[_\tâ]').sub('', temp)
        # print(2, temp)
        temp = re.compile(r' {2,}').sub(' ', temp)
        # print(3, temp)
        # temp = re.compile(r' +$').sub('', temp)
        # print(4, temp)
        # temp = re.compile(r'^[\s]+').sub('', temp)
        # print(5, temp)

        return temp.strip()

    @staticmethod
    def formatNumber(number):
        temp = html.unescape(number)
        temp = temp.replace('%', '')
        temp = temp.replace('"', '')
        temp = temp.replace("$", '')
        temp = temp.replace(',', '')
        temp = temp.replace('\'', '')
        temp = temp.replace('*', '')
        temp = temp.replace('#', '')
        temp = temp.strip()

        # temp = re.compile(r'[^\d.]').sub('', temp)

        return temp

    @staticmethod
    def formatTag(tag):
        temp = tag.replace('\'', '')
        temp = temp.replace('[', '')
        temp = temp.replace(']', '')
        temp = temp.strip()

        return temp

    macWebDriver = '/Users/ryanbilodeau/Desktop/Coding/WebDrivers/chromedriver'
    windowsWebDriver = 'C:\\Users\\Ryan Bilodeau\\Desktop\\Coding\\Selenium Drivers\\chromedriver.exe'

    @staticmethod
    def getDbConnection():
        filePath = '/Users/ryanbilodeau/Desktop/Coding/DbProps.txt'
        props = []
        with open(filePath, 'r') as fp:
            for count, line in enumerate(fp):
                props.append(line.strip())

        db = mysql.connector.connect(host=props[0],
                                     user=props[1],
                                     passwd=props[2],
                                     db=props[3])
        db.autocommit = False
        return db

class Months:
    @staticmethod
    def getMonthNum(month):
        switcher = {
            "January": 1,
            "February": 2,
            "March": 3,
            "April": 4,
            "May": 5,
            "June": 6,
            "July": 7,
            "August": 8,
            "September": 9,
            "October": 10,
            "November": 11,
            "December": 12
        }
        return switcher.get(month, "00")

    @staticmethod
    def strMonthToNum(month):
        switcher = {
            "jan": 1,
            "feb": 2,
            "mar": 3,
            "apr": 4,
            "may": 5,
            "jun": 6,
            "jul": 7,
            "aug": 8,
            "sep": 9,
            "oct": 10,
            "nov": 11,
            "dec": 12
        }

        return switcher.get(month[:3].strip().lower(), '00')


class DBManager:
    @staticmethod
    def insertGamesAndPrizes(games):
        if len(games) > 0:
            try:
                db = Statics.getDbConnection()
                cursor = db.cursor()

                sql = f"delete from Master.prize where FK in " \
                      f"(select PK from Master.game where state = '{games[0].state}' " \
                      f"and scrape_date = '{games[0].scrapeDate}');"
                cursor.execute(sql)

                sql = f"delete from game where scrape_date = '{games[0].scrapeDate}' and state = '{games[0].state}'"
                cursor.execute(sql)

                for game in games:
                    if len(game.prizes) < 1:
                        print('Game not inserted: ')
                        game.printSelf()
                        continue

                    sql = "INSERT INTO game (PK, state, name, number, price, odds, start_date, " \
                          "percent_sold, total_money_unclaimed, tickets_printed, number_of_prizes, scrape_date) " \
                          "VALUES ('{a}', '{b}', {c}, {d}, {e}, {f}, {g}, {h}, {i}, {j}, " \
                          "'{k}', '{m}')".format(a=game.getPrimaryKey(), b=game.state, c=game.getSQLName(),
                                                 d=game.getSQLNumber(), e=game.getSQLPrice(),
                                                 f=game.getSQLOdds(), g=game.getSQLStartDate(),
                                                 h=game.getSQLPercentSold(), i=game.getSQLTotalUnclaimed(),
                                                 j=game.getSQLTicketsPrinted(),
                                                 k=len(game.prizes), m=game.scrapeDate)

                    cursor.execute(sql)
                    game.printSelf()

                    for prize in game.prizes:
                        sql = "INSERT INTO prize (PK, FK, amount, odds, prizes_printed, " \
                              "prizes_remaining, scrape_date) " \
                              "VALUES ('{a}', '{b}', {c}, {d}, {e}, {f}, '{g}')".format(
                                a=prize.getPrimaryKey(), b=prize.getForeignKey(), c=prize.getSQLAmount(),
                                d=prize.getSQLOdds(), e=prize.getSQLPrizesPrinted(),
                                f=prize.getSQLPrizesRemaining(), g=prize.scrapeDate)

                        cursor.execute(sql)

                db.commit()
            except mysql.connector.Error as e:
                print(f'Error during db insertion: {e}')
                db.rollback()
            finally:
                cursor.close()
                db.close()



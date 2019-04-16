from ScraperScope import *
import mysql.connector
import operator
from datetime import datetime

db = Statics.getDbConnection()
db.autocommit = False
cursor = db.cursor()

# set start_date (if possible)

# ------------------------------------------------------------------------------------------

# set total_money_unclaimed
print('Setting total_money_unclaimed --------------------------------------------------------')
sql = f"select PK from game where scrape_date = '{Statics.getCurrentDate()}' and state in "\
        f"('California', 'Idaho', 'Louisiana', 'New Jersey', 'North Carolina', 'Ohio', " \
        f"'Oklahoma', 'Oregon', 'South Carolina', 'Texas')"

cursor.execute(sql)
for row in cursor.fetchall():
    key = row[0]
    key = key.replace('\'', '\'\'')
    sql = f"update game set total_money_unclaimed = " \
          f"(select sum(amount * prizes_remaining) from prize where FK = '{key}') " \
          f"where PK = '{key}'"
    cursor.execute(sql)

db.commit()
# ------------------------------------------------------------------------------------------

# set money_at_start
print('Setting money_at_start --------------------------------------------------------------')
sql = f"select PK from game where scrape_date = '{Statics.getCurrentDate()}' and state in "\
        f"('California', 'Idaho', 'Louisiana', 'Missouri', 'New Jersey', 'North Carolina', 'Oklahoma', "\
        f"'South Carolina', 'Texas')"

cursor.execute(sql)
for row in cursor.fetchall():
    key = row[0]
    key = key.replace('\'', '\'\'')
    sql = f"update game set money_at_start = " \
          f"(select sum(amount * prizes_printed) from prize where FK = '{key}') " \
          f"where PK = '{key}'"
    cursor.execute(sql)

db.commit()
# ------------------------------------------------------------------------------------------

# set averageProfit
print('Setting averageProfit ---------------------------------------------------------------------')
sql = f"select PK, total_money_unclaimed, percent_sold, tickets_printed, price from game " \
      f"where scrape_date = '{Statics.getCurrentDate()}' and state = 'Maine'"
cursor.execute(sql)
for row in cursor.fetchall():
    key = row[0]
    key = key.replace('\'', '\'\'')
    totalMoney = float(row[1])
    percentSold = float(row[2])
    if percentSold >= 99:
        continue

    ticketsPrinted = float(row[3])
    price = float(row[4])
    averageProfit = (totalMoney / (((100 - percentSold) / 100) * ticketsPrinted)) - price
    sql = f"update game set average_profit = {averageProfit} where PK = '{key}'"
    cursor.execute(sql)

db.commit()
# ------------------------------------------------------------------------------------------

# set oddsRank
print('Setting oddsRank -------------------------------------------------------------------------')
sql = f"select distinct state from game"
cursor.execute(sql)
for s in cursor.fetchall():
    state = s[0]
    dictionary = {}
    if state != 'Oregon':
        sql = f"select PK, odds from game where scrape_date = '{Statics.getCurrentDate()}' and state = '{state}'"
        cursor.execute(sql)
        for row in cursor.fetchall():
            key = row[0]
            key = key.replace('\'', '\'\'')
            odds = float(row[1])
            dictionary[key] = 100 / odds

    sortedDict = sorted(dictionary.items(), key=operator.itemgetter(1), reverse=True)
    i = 1
    for key, value in sortedDict:
        sql = f"update game set oddsRank = {i} where PK = '{key}'"
        cursor.execute(sql)
        i += 1

db.commit()
# ------------------------------------------------------------------------------------------

# set statsRank
print('Setting statsRank -------------------------------------------------------------------------')
sql = f"select distinct state from game"
cursor.execute(sql)
for s in cursor.fetchall():
    state = s[0]
    dictionary = {}
    if state == 'Maine':
        sql = f"select PK from game where scrape_date = '{Statics.getCurrentDate()}' and state = '{state}' " \
              f"and average_profit is not null"
        cursor.execute(sql)
        for row in cursor.fetchall():
            key = row[0]
            key = key.replace('\'', '\'\'')
            sql = f"select average_profit from game where PK = '{key}'"
            cursor.execute(sql)
            dictionary[key] = float(cursor.fetchone()[0])

    if state == 'Idaho' or state == 'Louisiana':
        sql = f"select PK from game where scrape_date = '{Statics.getCurrentDate()}' and state = '{state}'"
        cursor.execute(sql)
        for row in cursor.fetchall():
            key = row[0]
            key = key.replace('\'', '\'\'')
            sql = f"select (total_money_unclaimed * percent_sold) / price as p from game where PK = '{key}'"
            cursor.execute(sql)
            dictionary[key] = float(cursor.fetchone()[0])

    elif state == 'Missouri' or state == 'New Jersey' or state == 'North Carolina' or state == 'Oklahoma'\
            or state == 'South Carolina' or state == 'Texas':
        sql = f"select PK from game where scrape_date = '{Statics.getCurrentDate()}' and state = '{state}'"
        cursor.execute(sql)
        for row in cursor.fetchall():
            key = row[0]
            key = key.replace('\'', '\'\'')
            sql = f"select price, total_money_unclaimed, money_at_start, start_date from game where PK = '{key}'"
            cursor.execute(sql)
            results = cursor.fetchone()
            price = float(results[0])
            moneyUnclaimed = float(results[1])
            moneyAtStart = float(results[2])
            startDate = results[3]
            dayDiff = (datetime.strptime(Statics.getCurrentDate(), '%Y-%m-%d').date() -
                       startDate).days
            rank = ((moneyUnclaimed / moneyAtStart) / price) * dayDiff
            dictionary[key] = float(rank)

    sortedDict = sorted(dictionary.items(), key=operator.itemgetter(1), reverse=True)
    i = 1
    for key, value in sortedDict:
        sql = f"update game set statsRank = {i} where PK = '{key}'"
        cursor.execute(sql)
        i += 1

db.commit()
# ------------------------------------------------------------------------------------------

# set which date should be used
print('Setting which date should be used ----------------------------------------------------')
sql = f"insert into date_to_use (scrape_date) values ('{Statics.getCurrentDate()}')"
cursor.execute(sql)
db.commit()
db.close()

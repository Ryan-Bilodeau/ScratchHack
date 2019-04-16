from selenium import webdriver
import pymysql
import html
import datetime

conn = ''
cursor = conn.cursor()

time = datetime.datetime.now()
year = time.year
month = time.month
if month < 10:
    month = "0" + str(time.month)
day = time.day
if day < 10:
    day = "0" + str(time.day)
date = "{y}{m}{d}".format(y=year, m=month, d=day)

delScrapedTickets = "DELETE FROM scraped_tickets WHERE st_date='{a}'".format(a=date)
cursor.execute(delScrapedTickets)
conn.commit()

delScrapedPrizes = "DELETE FROM scraped_prizes WHERE sp_date='{a}'".format(a=date)
cursor.execute(delScrapedPrizes)
conn.commit()

driver = webdriver.Chrome(executable_path='C:\Python36-32\Scripts\chromedriver.exe')
driver.set_page_load_timeout(30)
driver.get("https://www.lottery.ok.gov/scratchers.asp")

tickets = []

table = driver.find_elements_by_tag_name("table")[5]
rows = table.find_elements_by_tag_name("tr")
rows.pop(0)
for row in rows:
    ticket = Ticket()

    img = row.find_elements_by_tag_name("img")[0]

    gameName = img.get_attribute("alt")
    gameName = str.replace(gameName, '\'', '\'\'')
    gameName = str.strip(gameName)
    ticket.name = html.unescape(gameName)

    temp = img.get_attribute("src")
    temp = temp.split("/")
    temp = temp[len(temp) - 1].split(".")
    ticket.number = temp[0]

    price = row.find_elements_by_tag_name("dd")[0].text
    ticket.price = str.strip(str.replace(price, "$", ""))

    ticket.odds = row.find_elements_by_tag_name("dd")[1].text

    temp = row.find_elements_by_tag_name("dd")[3].text
    temp = temp.split("/")
    year = temp[2]
    month = temp[0]
    if int(month) < 10:
        month = "0{month}".format(month=month)
    day = temp[1]
    if int(day) < 10:
        day = "0{day}".format(day=day)
    ticket.printDate = "{year}{month}{day}".format(year=year, month=month, day=day)

    tickets.append(ticket)


driver.get("https://www.lottery.ok.gov/remaining_prizes.asp")

body = driver.find_elements_by_tag_name("div")[13]
headers = body.find_elements_by_tag_name("div")
tables = body.find_elements_by_tag_name("tbody")
for i in range(0, len(headers)):
    temp = headers[i].find_element_by_tag_name("h3").text
    temp = temp.split("#")
    num = temp[1]

    cells = tables[i].find_elements_by_tag_name("tr")
    cells.pop(0)
    cells.pop(0)

    amounts = []
    printeds = []
    remainings = []
    for x in range(len(cells) - 5, len(cells)):
        amount = cells[x].find_elements_by_tag_name("td")[0].text
        amount = str.replace(amount, ",", "")
        amount = str.replace(amount, "$", "")
        amounts.append(amount)

        printed = cells[x].find_elements_by_tag_name("td")[2].text
        printed = str.replace(printed, ",", "")
        printeds.append(printed)

        remaining = cells[x].find_elements_by_tag_name("td")[1].text
        remaining = str.replace(remaining, ",", "")
        remainings.append(remaining)

    for ticket in tickets:
        if int(ticket.number) == int(num):
            ticket.prizeAmount = amounts
            ticket.prizesPrinted = printeds
            ticket.prizesRemaining = remainings

for ticket in tickets:
    sql = "INSERT INTO scraped_tickets(st_game_name, st_game_number, st_price, st_odds, " \
          "st_print_date, st_date)" \
          "VALUES ('{a}', '{b}', '{c}', '{d}', '{e}', '{f}')".format(a=ticket.name, b=ticket.number, c=ticket.price,
                                                                     d=ticket.odds, e=ticket.printDate,
                                                                     f=ticket.date)
    cursor.execute(sql)
    conn.commit()

    if ticket.prizeAmount is not None:
        for tik in range(0, len(ticket.prizeAmount)):
            sql = "INSERT INTO scraped_prizes(sp_game_number, sp_prize_amount, sp_prizes_printed, " \
                  "sp_prizes_remaining, sp_print_date, sp_date)" \
                  "VALUES ('{a}', '{b}', '{c}', '{d}', '{e}', '{f}')".format(a=ticket.number, b=ticket.prizeAmount[tik],
                                                                             c=ticket.prizesPrinted[tik],
                                                                             d=ticket.prizesRemaining[tik],
                                                                             e=ticket.printDate, f=ticket.date)
            cursor.execute(sql)
            conn.commit()

            print("Name: " + ticket.name + ", Number: " + ticket.number + ", Odds: " + ticket.odds +
                  ", PrintDate: " + ticket.printDate + ", Price " + ticket.price + ", PrizeAmount: "
                  + ticket.prizeAmount[tik] + ", Printed: " + ticket.prizesPrinted[tik] + ", Remaining: " +
                  ticket.prizesRemaining[tik])

driver.quit()
conn.close()

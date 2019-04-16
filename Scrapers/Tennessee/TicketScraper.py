from selenium import webdriver
from selenium.webdriver.common.by import By
import pymysql
import html
import datetime
from selenium.common.exceptions import NoSuchElementException, NoSuchAttributeException
from Tennessee.Ticket import Ticket

conn = ''
cursor = conn.cursor()

driver = webdriver.Chrome(executable_path='C:\Python36-32\Scripts\chromedriver.exe')
driver.set_page_load_timeout(10)
driver.get("http://www.tnlottery.com/thegames/instantgames/unclaimedprizes.aspx")

time = datetime.datetime.now()
year = time.year
month = time.month
if month < 10 :
    month = "0" + str(time.month)
day = time.day
if day < 10 :
    day = "0" + str(time.day)
date = "{y}{m}{d}".format(y=year, m=month, d=day)

tickets = []
executing = True

while executing:
    cells = driver.find_element_by_xpath("//table[@id='dlNewsItems']").find_elements_by_xpath(".//tr[@valign='middle']")
    for row in cells:
        tds = row.find_elements_by_class_name("smallblackcopy")
        ticket = Ticket()

        ticket.number = str.strip(str.replace(tds[0].text, ",", ""))

        temp = tds[1].find_element_by_tag_name("strong")
        temp = str.replace(temp.text, "\'", "\'\'")
        temp = str.strip(html.unescape(temp))
        temp = str.replace(temp, u"\u2122", "")
        temp = str.replace(temp, u"\u00AE", "")
        ticket.name = temp

        for prizes in tds[2].find_elements_by_tag_name("tr"):
            temp = str.replace(prizes.text, ",", "")
            temp = str.replace(temp, "$", "")
            ticket.prizeAmount.append(temp)

        for prizes in tds[3].find_elements_by_tag_name("tr"):
            temp = str.replace(prizes.text, ",", "")
            ticket.prizesRemaining.append(temp)

        tickets.append(ticket)

    try:
        temp = driver.find_element_by_xpath("//div[@id='pnlShowNewsItems']")
        button = temp.find_element_by_xpath(".//a[contains(@href, 'navNextPage0')]")
        button.click()
    except NoSuchElementException:
        print("Href doesn't exist")
        executing = False

driver.get("http://www.tnlottery.com/thegames/instantgames/default.aspx")
table = driver.find_element_by_xpath("//table[@id='dgGames']")
tds = table.find_elements_by_tag_name("td")
tds.pop(0)
tds.pop(0)
tds.pop(0)
tds.pop(0)

for i in range(0, len(tds)):
    if (i % 5 == 0):
        price = tds[i + 3].text
        price = str.replace(price, "$", "")

        temp = str(tds[i + 2].text)
        if (temp.count("#") == 1):
            temp = str.split(temp, "#")
            gameNumber = temp[1]

            for ticket in tickets:
                if ticket.number == gameNumber:
                    ticket.price = price

completedTickets = []
for ticket in tickets:
    if ticket.price != 0:
        completedTickets.append(ticket)


for ticket in completedTickets:
    sql = "INSERT INTO scraped_tickets(st_game_name, st_game_number, st_price, st_date)" \
          "VALUES('{a}', '{b}', '{c}', '{d}')".format(a=ticket.name, b=ticket.number, c=ticket.price, d=date)
    cursor.execute(sql)
    conn.commit()

    for i in range(0, len(ticket.prizesRemaining)):
        sql = "INSERT INTO scraped_prizes(sp_game_number, sp_prize_amount, sp_prizes_remaining, sp_date)" \
              "VALUES('{a}', '{b}', '{c}', '{d}')".format(a=ticket.number, b=ticket.prizeAmount[i],
                                                          c=ticket.prizesRemaining[i], d=date)
        cursor.execute(sql)
        conn.commit()

        print("Name: " + ticket.name + ", Number: " + ticket.number + ", Price: "
              + ticket.price + ", Amount: " + ticket.prizeAmount[i] + ", Remaining: " + ticket.prizesRemaining[i])

driver.quit()

from selenium import webdriver
import pymysql
import html
from selenium.webdriver.common.action_chains import ActionChains
import time

conn = ''
cursor = conn.cursor()

driver = webdriver.Chrome(executable_path='C:\Python36-32\Scripts\chromedriver.exe')
driver.set_page_load_timeout(30)
driver.fullscreen_window()
driver.get("https://www.nmlottery.com/top-prizes-not-yet-claimed.aspx")

tickets = []

table = driver.find_element_by_class_name("data")
rows = table.find_elements_by_tag_name("tr")
rows.pop(0)
for row in rows:
    ticket = Ticket()

    price = row.find_elements_by_tag_name("td")[0].text
    price = str.replace(price, ",", "")
    price = str.replace(price, "$", "")

    number = row.find_elements_by_tag_name("td")[1].text

    name = row.find_elements_by_tag_name("td")[2].text
    name = str.replace(name, '\'', '\'\'')
    name = html.unescape(name)
    name = str.strip(name)
    name = str.replace(name, "®", "")
    name = str.replace(name, "™", "")

    amount = row.find_elements_by_tag_name("td")[3].text
    amount = str.replace(amount, "$", "")
    amount = str.replace(amount, ",", "")

    remaining = row.find_elements_by_tag_name("td")[4].text
    remaining = str.replace(remaining, ",", "")
    remaining = str.replace(remaining, "*", "")

    ticket.price = price
    ticket.number = number
    ticket.name = name
    ticket.prizeAmount = amount
    ticket.prizesRemaining = remaining

    tickets.append(ticket)

driver.get("https://www.nmlottery.com/scratchers.aspx")
actions = ActionChains(driver)
table = driver.find_element_by_xpath("//table[@class='MDElementList MDclearBoth']")
actions.move_to_element(table).perform()
time.sleep(2)
buttons = table.find_elements_by_class_name("toggle-item")
print(len(buttons))

for button in buttons:
    actions.move_to_element(button).perform()
    time.sleep(2)
    button.click()

    parent = button.find_element_by_xpath("..")

    name = parent.find_elements_by_tag_name("div")[1].text
    name = str.replace(name, '\'', '\'\'')
    name = html.unescape(name)
    name = str.strip(name)
    name = str.replace(name, "®", "")
    name = str.replace(name, "™", "")

    price = parent.find_elements_by_tag_name("div")[3].text
    price = str.replace(price, "$", "")
    price = str.strip(price)

    printed = parent.find_elements_by_tag_name("div")[4].text
    printed = html.unescape(printed)
    temp = printed.split(":")
    temp = str.strip(temp[1])
    temp = temp.split(" ")
    year = temp[2]
    month = temp[0].strip()
    month = Months(month).getMonthNum()
    if int(month) < 10:
        month = "0" + str(month)
    day = temp[1]
    day = str.replace(day, ",", "")
    if int(day) < 10:
        day = "0" + str(day)
    printed = str(year) + str(month) + str(day)

    prizesPrinted = parent.find_element_by_class_name("prizes-and-odds").find_elements_by_tag_name("td")[2].text

    odds = parent.find_element_by_class_name("prizes-and-odds").find_elements_by_tag_name("p")[0].text
    temp = odds.split(" ")
    odds = temp[len(temp) - 1].strip()

    for ticket in tickets:
        if ticket.name == name and ticket.price == price:
            ticket.printDate = printed
            ticket.prizesPrinted = prizesPrinted
            ticket.odds = odds

            break

    time.sleep(2)

for ticket in tickets:
    if ticket.printDate != "":
        sql = "INSERT INTO scraped_tickets(st_game_name, st_game_number, st_price, st_odds, " \
              "st_prize_amount, st_prizes_printed, st_prizes_remaining, st_print_date, st_date)" \
              "VALUES('{a}', '{b}', '{c}', '{d}', " \
              "'{e}', '{f}', '{g}', '{h}', '{i}')".format(a=ticket.name, b=ticket.number, c=ticket.price,
                                                    d=ticket.odds, e=ticket.prizeAmount, f=ticket.prizesPrinted,
                                                    g=ticket.prizesRemaining, h=ticket.printDate, i=ticket.date)
        cursor.execute(sql)
        conn.commit()

        print("Name: " + ticket.name + ", Number: " + ticket.number + ", Odds: " + ticket.odds +
              ", PrintDate: " + ticket.printDate + ", Price " + ticket.price + ", PrizeAmount: "
              + ticket.prizeAmount + ", Printed: " + ticket.prizesPrinted + ", Remaining: " +
              ticket.prizesRemaining)

driver.quit()

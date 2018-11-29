from selenium import webdriver
import pymysql
import html
import datetime

conn = pymysql.connect(host="",
                       user="",
                       password="",
                       db="")
cursor = conn.cursor()

driver = webdriver.Chrome(executable_path='C:\Python36-32\Scripts\chromedriver.exe')
driver.set_page_load_timeout(10)
driver.get("https://oregonlottery.org/games/scratch-its/compare")

gameName = ""
price = 0
gameNumber = 0
prizeAmount = 0
prizesRemaining = 0

time = datetime.datetime.now()
year = time.year
month = time.month
if month < 10 :
    month = "0" + str(time.month)
day = time.day
if day < 10 :
    day = "0" + str(time.day)
date = "{y}{m}{d}".format(y=year, m=month, d=day)

button = driver.find_element_by_xpath("//select[@id='PageSize']")
button.click()
button.find_elements_by_tag_name("option")[0].click()

table = driver.find_element_by_xpath("//table[@id='compare-table']").find_element_by_tag_name('tbody')
trs = table.find_elements_by_xpath("./*")
trs.pop(0)
trs.pop(0)

for tr in trs:
    temp = tr.find_elements_by_tag_name("td")[1].text
    temp = str.replace(temp, "\'", "\'\'")
    temp = str.strip(html.unescape(temp))
    temp = str.replace(temp, u"\u2122", "")
    temp = str.replace(temp, u"\u00AE", "")
    gameName = temp

    price = tr.find_elements_by_tag_name("td")[3].text
    price = str.replace(price, "$", "")

    gameNumber = tr.find_elements_by_tag_name("td")[6].text

    sql = "INSERT INTO scraped_tickets(st_game_name, st_game_number, st_price, st_date)" \
          "VALUES ('{a}', '{b}', '{c}', '{d}')".format(a=gameName, b=gameNumber, c=price, d=date)
    cursor.execute(sql)
    conn.commit()

    tr.find_element_by_class_name("view-prizes").click()
    prizeRows = tr.find_elements_by_tag_name("td")[7].find_elements_by_tag_name("tr")
    prizeRows.pop(0)
    for row in range(1, len(prizeRows)):
        if row < 6:
            prizeAmount = prizeRows[row].find_elements_by_tag_name("td")[0].text
            prizeAmount = str.replace(prizeAmount, "$", "")

            prizesRemaining = prizeRows[row].find_elements_by_tag_name("td")[1].text

            sql = "INSERT INTO scraped_prizes(sp_game_number, sp_prize_amount," \
                  " sp_prizes_remaining, sp_date)" \
                  "VALUES ('{a}', '{b}', '{c}', '{d}')".format(a=gameNumber, b=prizeAmount,
                                                               c=prizesRemaining, d=date)
            cursor.execute(sql)
            conn.commit()

            print("Name: " + gameName + ", Price: " + price + ", Number: " + gameNumber +
                  ", Amount: " + prizeAmount + ", Remaining: " + prizesRemaining)

driver.quit()

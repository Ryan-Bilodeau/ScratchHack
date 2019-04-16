from selenium import webdriver
import html

driver = webdriver.Chrome(executable_path='C:\Python36-32\Scripts\chromedriver.exe')
driver.set_page_load_timeout(10)
driver.get("https://www.njlottery.com/en-us/instant-games/01420.html")

gameName = ""
gameNumber = ""
price = ""
printDate = ""
ticketsPrinted = ""
prizeAmount = ""
prizesPrinted = ""
prizesRemaining = ""

temp = driver.find_element_by_xpath("//li[@class='active']")
gameName = temp.text
gameName = str.replace(gameName, '\'', '\'\'')
gameName = str.strip(gameName)
gameName = html.unescape(gameName)

temp = driver.find_element_by_xpath("//p[starts-with(.,'Game #')]")
gameNumber = str.split(temp.text, "#")[1]
gameNumber = str.strip(gameNumber)

temp = driver.find_element_by_xpath("//div[@class='ticket-price']").find_element_by_xpath(".//div[@class='h5']")
price = str.split(temp.text, ".")[0]
price = str.strip(str.replace(price, "$", ""))

temp = driver.find_element_by_xpath("//div[@class='start-draw']").find_element_by_xpath(".//time")
printDate = temp.text
temp = str.split(printDate, "/")
year = temp[2]
month = temp[0]
if int(month) < 10:
    month = "0{month}".format(month=month)
day = temp[1]
printDate = "{year}{month}{day}".format(year=year, month=month, day=day)

temp = driver.find_element_by_xpath("//td[@id='totalTicketsPrinted']")
ticketsPrinted = temp.text
ticketsPrinted = str.replace(ticketsPrinted, ",", "")

cells = driver.find_element_by_xpath("//table[@class='table--prizes-remain']").find_elements_by_tag_name("tr")

print("Game Name: {gn}, Game Number: {num}, Price: {pr}, Print Date: {pd}, Tickets Printed: {tp}".format(gn=gameName,
                                                                                                     num=gameNumber,
                                                                                                     pr=price,
                                                                                                     pd=printDate,
                                                                                                     tp=ticketsPrinted))

for cell in range(1, 6):
    if cell < len(cells) - 2:
        prizeAmount = cells[cell].find_elements_by_tag_name("td")[0].text
        prizeAmount = str.replace(prizeAmount, "$", "")
        prizeAmount = str.replace(prizeAmount, ",", "")

        if prizeAmount.isnumeric() == False:
            if str.find(prizeAmount, "Month") > 0:
                prizeAmount = int(str.split(prizeAmount, " ")[0]) * 12

        prizesPrinted = cells[cell].find_elements_by_tag_name("td")[1].text
        prizesPrinted = str.replace(prizesPrinted, ",", "")

        prizesRemaining = cells[cell].find_elements_by_tag_name("td")[2].text
        prizesRemaining = str.replace(prizesRemaining, ",", "")

        print("Prize Amount: {pa}, Prizes Printed: {pp} Prizes Remaining: {pr}".format(pa=prizeAmount,
                                                                                       pp=prizesPrinted,
                                                                                       pr=prizesRemaining))
    else:
        break
print("--------------------------------------------------------------------------------------------------------------")

driver.quit()
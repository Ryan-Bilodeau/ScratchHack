import datetime


class Ticket:
    name: str
    number: str
    price: str
    prizeAmount: str
    prizesRemaining: str

    printDate: str
    prizesPrinted: str
    odds: str

    date: str

    def __init__(self):
        self.name = ""
        self.number = ""
        self.price = ""
        self.prizeAmount = ""
        self.prizesRemaining = ""

        self.printDate = ""
        self.prizesPrinted = ""
        self.odds = ""

        time = datetime.datetime.now()
        year = time.year
        month = time.month
        if month < 10:
            month = "0" + str(time.month)
        day = time.day
        if day < 10:
            day = "0" + str(time.day)
        self.date = "{y}{m}{d}".format(y=year, m=month, d=day)

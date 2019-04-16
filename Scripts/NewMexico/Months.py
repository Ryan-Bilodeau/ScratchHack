from enum import Enum


class Months:
    def getMonthNum(self):
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
        return switcher.get(self.month, "00")

    month: str

    def __init__(self, month):
        self.month = month

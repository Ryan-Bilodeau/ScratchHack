import re
from ScraperScope import *
from datetime import datetime


x = datetime.strptime('2019-03-09', '%Y-%m-%d')
y = datetime.strptime('2019-03-03', '%Y-%m-%d')

print((x - y).days)

# junk = '''
# Approximately 5.4 million RUBY RED RICHES tickets are initially planned in this game. The New Jersey Lottery reserves the right to subsequently increase this quantity of tickets. Should additional tickets be introduced, prize levels and frequency of winning will be consistent with the initial quantity of tickets. In the RUBY RED RICHES Instant Scratch-Offs Game, New Jersey allocates approximately 65% of the gross receipts, net of free tickets, to prizes. On the average, 1 in 8 better than 1 ticket in 5 wins a prize. Odds and number of winners may vary based on sales, distribution and claims.
# '''
# print(junk)
#
# temp = re.findall(r'1 ticket in \d+|1 in \d+', junk)
# print(temp)

# p = re.compile(r',').sub('', junk)
# p = re.compile(r'\s+').sub(' ', p)
# nums = re.findall(r'\$\d+ \d+ \d+', p)
# print(nums)

# formatted = re.compile(r'[^\w\s!\'#$&,?%â\-]').sub('', junk)
# print(formatted)
# formatted = re.compile(r'[_\n\t]').sub('', formatted)
# print(formatted)
# formatted = re.compile(r' {2,}').sub(' ', formatted)
# print(formatted)
# print(formatted.strip())

# num = '$100,000.00          adsf;lajsdl;f '
#
# formatted = re.compile(r'[^\d.]').sub('', num)
# print(formatted)



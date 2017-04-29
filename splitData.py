import pandas as pd
import numpy as np

def p2f(x):
    '''
    percent to float
    x: Str
    return: Float
    '''
    if pd.isnull(x):
        return
    return float(x.strip('%'))

mySeed = 100  # set random seed for splitting data

loanBook = pd.read_csv('loan.csv')
header = list(loanBook)

loanBook2016 = loanBook[:0]
for quarter in range(4):
    fileName = 'LoanStats_2016Q' + str(quarter + 1) + '.csv'
    loanBookTemp = pd.read_csv(fileName, skiprows = 1, usecols = header)
    loanBookTemp = loanBookTemp[:-2]
    loanBook2016 = pd.concat([loanBook2016, loanBookTemp])

# reset the row index
loanBook2016.reset_index(drop = True, inplace = True)

# add id and member_id
loanBook2016['id'] = list(range(len(loanBook2016)))
loanBook2016['member_id'] = list(range(len(loanBook2016)))

# change the percent (str) to float numbers between 0 to 100.
loanBook2016['int_rate'] = [p2f(x) for x in loanBook2016['int_rate']]
loanBook2016['revol_util'] = [p2f(x) for x in loanBook2016['revol_util']]

# split data
train = loanBook.sample(frac = 0.75, random_state = mySeed, axis = 0)
testId = loanBook.index.difference(train.index)
test = loanBook.iloc[testId]
test = pd.concat([test, loanBook2016])

# create the true label of the test data
defaultStatus = ["Charged Off",
                  "Default",
                  "Does not meet the credit policy. Status:Charged Off",
                  "Late (16-30 days)",
                  "Late (31-120 days)"
                  ]
defaultDict = {x:1 for x in defaultStatus}
label = [1 if x in defaultDict else 0 for x in test['loan_status']]
testLabel = pd.DataFrame({'id': test['id'], 'y': label})

# remove the true label in the test data
del test['loan_status']

train.to_csv(path_or_buf = 'train.csv', sep = ',', na_rep = '', 
    index = False, line_terminator = '\n')
test.to_csv(path_or_buf = 'test.csv', sep = ',', na_rep = '', 
    index = False, line_terminator = '\n')
testLabel.to_csv(path_or_buf = 'label.csv', sep = ',', na_rep = '', 
    index = False, line_terminator = '\n')
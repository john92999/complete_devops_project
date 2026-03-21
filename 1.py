#1
print('hello Lambda Course')

#2
response = 3
print(response)

#3
response = {1: 'John', 2: 'Wesley', 3: 'Chintalapudi'}
print(response[2])

#4
response= {1: 'John', 2: {'books': 'arch', 'aws': 'lambda'}}
print(response[2]['aws'])

#5
response = {
    'Buckets': [{
        'Name': 'string',
        'CreationDate': 25

    },],
    'owner': {
        'DisplayName': 'string',
        'ID': 'string'
    }
}

print(response['Buckets'])

#6
list = [1, 4, 'for', 6, 'Anisha']
print(list[0:5:1])

#7
nestedList = [[1,2,3], [4,5,6], [7,8,9]]
print(nestedList[1][0])

#8
response = {
    'Buckets': [
        {
            'Name': 'string',
            'CreationDate': 25
        },
        {
            'Name': 'Bucket2',
            'CreationDate': 26
        },
    ],
    'owner': {
        'DisplayName': 'string',
        'ID': 'string'
    }
}

print(response['Buckets'][1])

#9
response = [[1,2,3], [4,5,6], [7,8,9]]
print(type(response))

#10
def evenOdd(x):
    if (x%2 == 0):
        print('even')
    else:
        print('Odd')

evenOdd(2)
evenOdd(3)
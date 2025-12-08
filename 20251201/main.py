with open('input.txt', 'r') as file:
    data = file.read().splitlines()
start = 50
count = 0
for k in data :
    if k[0]=='R':
        start = start + int(k[1:])
        count = count + start//100
        start = start % 100
    if k[0]=='L':
        if start==0 :
            count = count - 1
        start = start - int(k[1:])
        count = count - start//100
        start = start % 100
        if start==0 :
            count = count + 1
print(count)
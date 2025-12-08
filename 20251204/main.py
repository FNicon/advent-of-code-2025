from time import perf_counter
t1_start = perf_counter()
import copy
with open('input.txt', 'r') as file:
    data = file.read().splitlines()
mat=[]
pad=[]
count=1
total=0
for a in range(141) :
    pad.append(0)
mat.append(pad)
for k in data :
    line = [0]
    for i in range(138):
        if k[i]=="@": line.append(1)
        if k[i]==".": line.append(0)
    line.append(0)
    mat.append(line)
mat.append(pad)
mat_after = copy.deepcopy(mat)
while count>0:
    count=0
    mat = copy.deepcopy(mat_after)
    for x in range(139):
        for y in range(139):
            if mat[x+1][y+1]==1:
                check = mat[x][y] + mat[x][y+1] + mat[x][y+2] + mat[x+1][y] + mat[x+1][y+2] + mat[x+2][y] + mat[x+2][y+1] + mat[x+2][y+2]
                if check<4:
                    mat_after[x+1][y+1]=0
                    count+=1
    total = total + count

t1_stop = perf_counter()

print("Elapsed time:", t1_stop, t1_start)


print("Elapsed time during the whole program in seconds:",
                                        t1_stop-t1_start)

print(total)

import sys

def toSec(s):
    l = s.split('.')
    l = l[0].split(':')
    return int(l[0])*3600 + int(l[1])*60 + int(l[2])

file = open(sys.argv[1],'r')
lines = file.readlines()
file.close()
new_lines = []
for i in range(len(lines)):
    line = lines[i]
    print "before: " + lines[i]
    tokens = line.split()
    line = str(tokens[0]) + " " + str(toSec(tokens[1])) + '\n'
    new_lines.append(line)
    print "after: " + line

file = open(sys.argv[1].split('.')[0] + '_modified.csv','w')
file.writelines(new_lines)
file.close()

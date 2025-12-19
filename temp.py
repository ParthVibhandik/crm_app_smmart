import random

l = ['Ashish', 'Chirag', 'Dhaval', 'Parth']

c1 = random.choice(l)


c2 = random.choice(l)
while c1 == c2:
    c2 = random.choice(l)
print(c1, c2)
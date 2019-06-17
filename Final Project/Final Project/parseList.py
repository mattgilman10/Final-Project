print("HELLO")
try:  
    fp = open('Craigslist_list.txt', 'r')
    # do stuff here
    for line in fp:
        print(line)
finally:  
    fp.close()

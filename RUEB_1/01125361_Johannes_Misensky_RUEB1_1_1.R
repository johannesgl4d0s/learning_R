n = 1000000
li = list()
for (i in (1:n)) 
  if (i == 2L || all(i %% 2L:ceiling(sqrt(i))) != 0) li <- append(li,i)
    


li

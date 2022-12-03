dat = c()

for (i in (0:4))
  for (z in (0:4)) dat = append(dat,abs(i-z))



n   = 5
k   = 5

x   = matrix(data=dat, nrow=n, ncol=k)
x

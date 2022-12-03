s = c(2,3,5,7,11,13,17,19,23,29)



dat = c()
for (b in 1:length(s))
  for(i in 1:length(s)-1) dat = append(dat, s[b] + s[b]*i)
dat  

n   = 10
k   = 10

x   = matrix(data=dat, nrow=n, ncol=k)

t(x)

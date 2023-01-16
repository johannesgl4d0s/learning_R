m = c() # create empty vektor

for(i in 1:10000) {
  m = c(m,mean(rnorm(1000, 0))) # append the mean of normal dist to m 
  
}

hist(m)
mean(m)


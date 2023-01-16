x = rnorm(1000,  mean = 1, sd = 1.5) # n = 1000
y = rnorm(1000, mean = 5, sd = 2)
z = c(x,y)
plot(density(z),main="Dichtefunktion")

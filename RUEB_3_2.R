x = rnorm(1000)

z = cumsum(x^2)

hist(x)

plot(z,ylim = c(0, 1000),xlab="Kumulierte Qudrate von x",main="Summe der Quadrate von Normalverteilung")

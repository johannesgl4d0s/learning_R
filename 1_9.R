

Overall.Cond <- 1:7
Freq <- c(17,15,9,5,3,1)
myhist <-list(breaks=Overall.Cond, counts=Freq, density=Freq/diff(Overall.Cond),
              xname="Overall Cond")
class(myhist) <- "histogram"
plot(myhist)


#der median liegt zischen dem 25 und 26 Wert DH. bei 500<x≤1000
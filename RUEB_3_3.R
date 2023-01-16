tracker = 0 # set some sort of Tracker
#1000 double dice rolls
for (i in 1:100000) {
  if (4 %in% floor(runif(2, min=1, max=6))){#check if 4 is in double
    tracker = tracker +1 # if true add 1 to tracker
  }
    
  
}
chance_of_one_four = tracker/100000
chance_of_one_four

#check with math:
#dice A     #dice B
1/6     +    1/6


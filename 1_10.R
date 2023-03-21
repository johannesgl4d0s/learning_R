install.packages("psych")

library(tidyverse)
library(nycflights13)
library(psych)

library(ggplot2)

view(flights)
describe(flights)
#Welche Jahre wurden aufgezeichnet?
#das Jahr 2013 wurde aufgezeichnet
#Sind die Jahre vollständig vorhanden?
new <- flights %>%
  group_by(month) %>%
  filter(!is.na(as.numeric(day))) %>%
  summarise(unique(day)) 
new
#Es sind insgesamt 365 Tage erfasst - es gibt aber nan Werte im Datensatz

#Wie viele Airlines wurden aufgezeichnet?

length(unique(flights$carrier))

#Es sind 16 airlines erfasst

#Welche Airline hat die größte erwartete Verspätung bei der Ankunft?


air <- flights %>%
  group_by(carrier) %>%
  filter(!is.na(as.numeric(arr_delay))) %>%
  summarise(mean(arr_delay)) 


arrange(air, desc(air$`mean(arr_delay)`))
#die airline F9 hatte im schnitt die größte verspätung bei der ankunft

#Welche Airline hat die „zuverlässigste“ Verspätung beim Abflug?

air2 <- flights %>%
  group_by(carrier) %>%
  filter(!is.na(as.numeric(dep_delay))) %>%
  summarise(mean(dep_delay)) 

arrange(air2, desc(air2$`mean(dep_delay)`))[1:1,]

#wieder F9

df = arrange(air, air$`mean(arr_delay)`)[1:10,]
df

ggplot(df, aes(fill=carrier,y=`mean(arr_delay)`, x=reorder(carrier,`mean(arr_delay)`))) + 
  geom_point() +
  expand_limits(y=0) +
  xlab("Airline") + ylab("durchsch. Verspätung") +
  ggtitle("Average Departure Delay By Airline")



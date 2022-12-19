install.packages("stringr")

install.packages("zip")

install.packages("filesstrings")

library(zip)

library(stringr)
library(filesstrings)

myURL <- 'http://www.it-webservices.com/FHWN_WS2022/covid-world-vaccinationprogress.zip'

# Zielverzeichnis
zielverzeichnis <- './data'

# Anlegen eines Download-Verzeichnisses
if (!dir.exists(zielverzeichnis)) {
  print("Verzeichnis existiert nicht und wird angelegt....")
  dir.create(zielverzeichnis)
} else {
  print("Verzeichnis existiert und Download beginnt...")
}

download.file(myURL,destfile = paste(zielverzeichnis,'covid-world-vaccination-progress.zip',sep="/"))

string <- list.files(path = zielverzeichnis)


if(str_sub(string, -3) == 'zip')
  unzip(paste(zielverzeichnis,string,sep="/"),exdir = zielverzeichnis)


archiv <- './data/archiv'    

if (!dir.exists(archiv)) {
  print("Verzeichnis existiert nicht und wird angelegt....")
  dir.create(archiv)
} 

file.move(paste(zielverzeichnis,string,sep="/"), archiv)


  
list_file <- list.files(path = zielverzeichnis,pattern = "*.csv")

list_file[1]

for(i in 1:length(list_file)) {                    # assign function within loop
  
  nam <- paste("variable", i, sep = "_")
  assign(nam, read.csv(paste(zielverzeichnis,list_file[i],sep="/")))
}

colnames(variable_1)

num <- 0
for (i in colnames(variable_1)){
  num <- num +1
}
print(paste('„Die Datenquelle datenquelle_1 besitzt',num,'Attribute'))


datenquellen = list(variable_1,variable_2)

saveRDS(datenquellen, file = "datenquellen.rds")

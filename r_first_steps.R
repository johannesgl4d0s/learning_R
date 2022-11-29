for (i in 1:10) {
  print(i)
}

for (i in 1:100) {
  if (i%%5) {next}
  print(i)
  
}

x = c("a","b","c","d","e")

for (i in 1:length(x)) {
  print(x[i])
  
}

for (i in seq_along(x)) {
  print(x[i])
}

x = matrix(1:10,2,5)
x


for (i in seq_len(nrow(x))) {
  
  for (j in seq_len(ncol(x))) {
    print(x[i,j])
    
  }
}
s = c(2,3,5,7,11,13,17,19,23,29)

n = (13:1300)

n_liste =list()

for (b in (1:length(n)))
  for (i in (1:length(s))) {
    if (b %% s[i] == 0) 
    print(b)
    n_liste <- append(n_liste, b)
    break
  }

for (i in 1:length(n_liste)) {
  assign(paste0("n_",i), n_liste[[i]])
}
 
n_3    





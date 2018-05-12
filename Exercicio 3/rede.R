#libs
set.seed(1234567890)
library(neuralnet)
library(hydroGOF)
library(leaps)
library(arules)

#mudar diretoria para o projeto
#setwd("/Users/josesousa/Documents/SRCR/Exercicio\ 3")

setwd("/home/yoda45/Desktop/git/SRCR/Exercicio\ 3")

#setwd("/Users/Asus/Desktop/SRCR/Trabalho")

#carregar ficheiro
#dados <- read.csv(file="bank.csv", header=TRUE, sep=",")
dados <- read.csv(file="bank-additional.csv", header=TRUE, sep=";")


#not working
#dados$pdays <-  as.numeric(discretize(dados$pdays, method = "frequency", breaks = 10))

dados$age <- as.double(discretize(dados$age,method = "cluster",breaks = 66, labels = c(1:66)))

dados$age[dados$age == 1] <- 0.0151
dados$age[dados$age == 2] <- 0.0303
dados$age[dados$age == 3] <- 0.0455
dados$age[dados$age == 4] <- 0.0606
dados$age[dados$age == 5] <- 0.0758
dados$age[dados$age == 6] <- 0.0909
dados$age[dados$age == 7] <- 0.1061
dados$age[dados$age == 8] <- 0.1212
dados$age[dados$age == 9] <- 0.1364
dados$age[dados$age == 10] <- 0.1515
dados$age[dados$age == 11] <- 0.1667
dados$age[dados$age == 12] <- 0.1818
dados$age[dados$age == 13] <- 0.1970
dados$age[dados$age == 14] <- 0.2121
dados$age[dados$age == 15] <- 0.2272
dados$age[dados$age == 16] <- 0.2424
dados$age[dados$age == 17] <- 0.2576
dados$age[dados$age == 18] <- 0.2727
dados$age[dados$age == 19] <- 0.2879
dados$age[dados$age == 20] <- 0.3030
dados$age[dados$age == 21] <- 0.3182
dados$age[dados$age == 22] <- 0.3333
dados$age[dados$age == 23] <- 0.3485
dados$age[dados$age == 24] <- 0.3636
dados$age[dados$age == 25] <- 0.3788
dados$age[dados$age == 26] <- 0.3939
dados$age[dados$age == 27] <- 0.4090
dados$age[dados$age == 28] <- 0.4242
dados$age[dados$age == 29] <- 0.4394
dados$age[dados$age == 30] <- 0.4545
dados$age[dados$age == 31] <- 0.4697
dados$age[dados$age == 32] <- 0.4848
dados$age[dados$age == 33] <- 0.5000
dados$age[dados$age == 34] <- 0.5151
dados$age[dados$age == 35] <- 0.5303
dados$age[dados$age == 36] <- 0.5454
dados$age[dados$age == 37] <- 0.5606
dados$age[dados$age == 38] <- 0.5757
dados$age[dados$age == 39] <- 0.5909
dados$age[dados$age == 40] <- 0.6060
dados$age[dados$age == 41] <- 0.6212
dados$age[dados$age == 42] <- 0.6363
dados$age[dados$age == 43] <- 0.6515
dados$age[dados$age == 44] <- 0.6667
dados$age[dados$age == 45] <- 0.6818
dados$age[dados$age == 46] <- 0.6969
dados$age[dados$age == 47] <- 0.7121
dados$age[dados$age == 48] <- 0.7272
dados$age[dados$age == 49] <- 0.7424
dados$age[dados$age == 50] <- 0.7575
dados$age[dados$age == 51] <- 0.7727
dados$age[dados$age == 52] <- 0.7878
dados$age[dados$age == 53] <- 0.8003
dados$age[dados$age == 54] <- 0.8181
dados$age[dados$age == 55] <- 0.8333
dados$age[dados$age == 56] <- 0.8484
dados$age[dados$age == 57] <- 0.8636
dados$age[dados$age == 58] <- 0.8787
dados$age[dados$age == 59] <- 0.8939
dados$age[dados$age == 60] <- 0.9090
dados$age[dados$age == 61] <- 0.9242
dados$age[dados$age == 62] <- 0.9393
dados$age[dados$age == 63] <- 0.9545
dados$age[dados$age == 64] <- 0.9697
dados$age[dados$age == 65] <- 0.9848
dados$age[dados$age == 66] <- 0.9999




dados$job <- as.double(discretize(dados$job,method = "cluster",breaks = 12, labels = c(0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.1,1.2)))
                       

dados$job[dados$job == 1] <- 0.0833
dados$job[dados$job == 2] <- 0.1666
dados$job[dados$job == 3] <- 0.2499
dados$job[dados$job == 4] <- 0.3333
dados$job[dados$job == 5] <- 0.4166
dados$job[dados$job == 6] <- 0.4999
dados$job[dados$job == 7] <- 0.5833
dados$job[dados$job == 8] <- 0.6666
dados$job[dados$job == 9] <- 0.7499
dados$job[dados$job == 10] <- 0.8333
dados$job[dados$job == 11] <- 0.9166
dados$job[dados$job >= 12] <- 0.9999


dados$marital <- as.double(discretize(dados$marital,method = "cluster", breaks = 3, labels = c(0.1,0.2,0.3)))

dados$martial[dados$marital == 1] <- 0.25
dados$marital[dados$marital == 2] <- 0.50
dados$marital[dados$marital == 3] <- 0.75


dados$education <- as.double(discretize(dados$education,method = "cluster", breaks = 8, labels = c(0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8)))

dados$education[dados$education == 1] <- 0.125
dados$education[dados$education == 2] <- 0.250
dados$education[dados$education == 3] <- 0.375
dados$education[dados$education == 4] <- 0.500
dados$education[dados$education == 5] <- 0.625
dados$education[dados$education == 6] <- 0.750
dados$education[dados$education == 7] <- 0.875
dados$education[dados$education == 8] <- 1


dados$default <- as.double(discretize(dados$default,method="cluster",breaks =2, labels = c(0.1,0.2)))

dados$default[dados$default == 1] <- 0.5
dados$default[dados$default == 2] <- 1


dados$housing <- as.double(discretize(dados$housing,method="cluster",breaks =2, labels = c(0.1,0.2)))

dados$housing[dados$housing == 1] <- 0.5
dados$housing[dados$housing == 2] <- 1


dados$loan <- as.double(discretize(dados$loan,method="cluster",breaks =2, labels = c(0.1,0.2)))

dados$loan[dados$loan == 1] <- 0.5
dados$loan[dados$loan == 2] <- 1


dados$campaign <- as.double(discretize(dados$campaign,method="cluster",breaks =25, labels = c(1:25)))

dados$campaign[dados$campaign == 1] <- 0.0400
dados$campaign[dados$campaign == 2] <- 0.0800
dados$campaign[dados$campaign == 3] <- 0.1200
dados$campaign[dados$campaign == 4] <- 0.1600
dados$campaign[dados$campaign == 5] <- 0.2000
dados$campaign[dados$campaign == 6] <- 0.2400
dados$campaign[dados$campaign == 7] <- 0.2800
dados$campaign[dados$campaign == 8] <- 0.3200
dados$campaign[dados$campaign == 9] <- 0.3600
dados$campaign[dados$campaign == 10] <- 0.4000
dados$campaign[dados$campaign == 11] <- 0.4400
dados$campaign[dados$campaign == 12] <- 0.4800
dados$campaign[dados$campaign == 13] <- 0.5200
dados$campaign[dados$campaign == 14] <- 0.5600
dados$campaign[dados$campaign == 15] <- 0.6000
dados$campaign[dados$campaign == 16] <- 0.6400
dados$campaign[dados$campaign == 17] <- 0.6800
dados$campaign[dados$campaign == 18] <- 0.7200
dados$campaign[dados$campaign == 19] <- 0.7600
dados$campaign[dados$campaign == 20] <- 0.8000
dados$campaign[dados$campaign == 21] <- 0.8400
dados$campaign[dados$campaign == 22] <- 0.8800
dados$campaign[dados$campaign == 23] <- 0.9200
dados$campaign[dados$campaign == 24] <- 0.9600
dados$campaign[dados$campaign == 25] <- 1.0000  

dados$pdays <- as.double(discretize(dados$pdays,method = "cluster",breaks = 21, labels=c(1:21)))

dados$pdays[dados$pdays == 1] <- 0.0476
dados$pdays[dados$pdays == 2] <- 0.0952
dados$pdays[dados$pdays == 3] <- 0.1429
dados$pdays[dados$pdays == 4] <- 0.1905
dados$pdays[dados$pdays == 5] <- 0.2381
dados$pdays[dados$pdays == 6] <- 0.2857
dados$pdays[dados$pdays == 7] <- 0.3333
dados$pdays[dados$pdays == 8] <- 0.3810
dados$pdays[dados$pdays == 9] <- 0.4286
dados$pdays[dados$pdays == 10] <- 0.4762
dados$pdays[dados$pdays == 11] <- 0.5238
dados$pdays[dados$pdays == 12] <- 0.5714
dados$pdays[dados$pdays == 13] <- 0.6190
dados$pdays[dados$pdays == 14] <- 0.6667
dados$pdays[dados$pdays == 15] <- 0.7143
dados$pdays[dados$pdays == 16] <- 0.7619
dados$pdays[dados$pdays == 17] <- 0.8095
dados$pdays[dados$pdays == 18] <- 0.8571
dados$pdays[dados$pdays == 19] <- 0.9048
dados$pdays[dados$pdays == 20] <- 0.9524
dados$pdays[dados$pdays == 21] <- 1.0000

dados$previous <- as.double(discretize(dados$previous,method = "cluster",breaks = 7, labels=c(1:7)))

dados$previous[dados$previous == 1] <- 0.1429
dados$previous[dados$previous == 2] <- 0.2857
dados$previous[dados$previous == 3] <- 0.4286
dados$previous[dados$previous == 4] <- 0.5714
dados$previous[dados$previous == 5] <- 0.7143
dados$previous[dados$previous == 6] <- 0.8571
dados$previous[dados$previous == 7] <- 1.0000


dados$poutcome<- as.double(discretize(dados$poutcome,method = "cluster",breaks = 3, labels=c(1,2,3)))

dados$poutcome[dados$poutcome == 1] <- 0.33333
dados$poutcome[dados$poutcome == 2] <- 0.66666
dados$poutcome[dados$poutcome == 3] <- 0.99999

dados$emp.var.rate<- as.double(discretize(dados$emp.var.rate,method = "cluster",breaks = 9, labels=c(-7,-6,-5,-4,-3,-2,-1,1,2)))



dados$emp.var.rate[dados$emp.var.rate == -7] <- -1.0000
dados$emp.var.rate[dados$emp.var.rate == -6] <- -0.8571
dados$emp.var.rate[dados$emp.var.rate == -5] <- -0.7143
dados$emp.var.rate[dados$emp.var.rate == -4] <- -0.5714
dados$emp.var.rate[dados$emp.var.rate == -3] <- -0.4286
dados$emp.var.rate[dados$emp.var.rate == -2] <- -0.2857
dados$emp.var.rate[dados$emp.var.rate == -1] <- -0.1428
dados$emp.var.rate[dados$emp.var.rate == 1] <- 0.5000
dados$emp.var.rate[dados$emp.var.rate == 2] <- 1.0000


dados$cons.price.idx <- as.double(discretize(dados$cons.price.idx,method = "cluster",breaks = 26, labels=c(1:26)))

dados$cons.price.idx[dados$cons.price.idx == 1] <- 0.0385
dados$cons.price.idx[dados$cons.price.idx == 2] <- 0.0769
dados$cons.price.idx[dados$cons.price.idx == 3] <- 0.1154
dados$cons.price.idx[dados$cons.price.idx == 4] <- 0.1538
dados$cons.price.idx[dados$cons.price.idx == 5] <- 0.1923
dados$cons.price.idx[dados$cons.price.idx == 6] <- 0.2308
dados$cons.price.idx[dados$cons.price.idx == 7] <- 0.2692
dados$cons.price.idx[dados$cons.price.idx == 8] <- 0.3077
dados$cons.price.idx[dados$cons.price.idx == 9] <- 0.3461
dados$cons.price.idx[dados$cons.price.idx == 10] <- 0.3846
dados$cons.price.idx[dados$cons.price.idx == 11] <- 0.4231
dados$cons.price.idx[dados$cons.price.idx == 12] <- 0.4615
dados$cons.price.idx[dados$cons.price.idx == 13] <- 0.5000
dados$cons.price.idx[dados$cons.price.idx == 14] <- 0.5385
dados$cons.price.idx[dados$cons.price.idx == 15] <- 0.5769
dados$cons.price.idx[dados$cons.price.idx == 16] <- 0.6154
dados$cons.price.idx[dados$cons.price.idx == 17] <- 0.6538
dados$cons.price.idx[dados$cons.price.idx == 18] <- 0.6923
dados$cons.price.idx[dados$cons.price.idx == 19] <- 0.7308
dados$cons.price.idx[dados$cons.price.idx == 20] <- 0.7692
dados$cons.price.idx[dados$cons.price.idx == 21] <- 0.8077
dados$cons.price.idx[dados$cons.price.idx == 22] <- 0.8462
dados$cons.price.idx[dados$cons.price.idx == 23] <- 0.8846
dados$cons.price.idx[dados$cons.price.idx == 24] <- 0.9231
dados$cons.price.idx[dados$cons.price.idx == 25] <- 0.9615
dados$cons.price.idx[dados$cons.price.idx == 26] <- 1.0000

dados$cons.conf.idx <- as.double(discretize(dados$cons.conf.idx,method = "cluster",breaks = 26, labels=c(-26:-1)))

dados$cons.conf.idx[dados$cons.conf.idx == -1] <- -0.0385
dados$cons.conf.idx[dados$cons.conf.idx == -2] <- -0.0769
dados$cons.conf.idx[dados$cons.conf.idx == -3] <- -0.1154
dados$cons.conf.idx[dados$cons.conf.idx == -4] <- -0.1538
dados$cons.conf.idx[dados$cons.conf.idx == -5] <- -0.1923
dados$cons.conf.idx[dados$cons.conf.idx == -6] <- -0.2308
dados$cons.conf.idx[dados$cons.conf.idx == -7] <- -0.2692
dados$cons.conf.idx[dados$cons.conf.idx == -8] <- -0.3077
dados$cons.conf.idx[dados$cons.conf.idx == -9] <- -0.3461
dados$cons.conf.idx[dados$cons.conf.idx == -10] <- -0.3846
dados$cons.conf.idx[dados$cons.conf.idx == -11] <- -0.4231
dados$cons.conf.idx[dados$cons.conf.idx == -12] <- -0.4615
dados$cons.conf.idx[dados$cons.conf.idx == -13] <- -0.5000
dados$cons.conf.idx[dados$cons.conf.idx == -14] <- -0.5385
dados$cons.conf.idx[dados$cons.conf.idx == -15] <- -0.5769
dados$cons.conf.idx[dados$cons.conf.idx == -16] <- -0.6154
dados$cons.conf.idx[dados$cons.conf.idx == -17] <- -0.6538
dados$cons.conf.idx[dados$cons.conf.idx == -18] <- -0.6923
dados$cons.conf.idx[dados$cons.conf.idx == -19] <- -0.7308
dados$cons.conf.idx[dados$cons.conf.idx == -20] <- -0.7692
dados$cons.conf.idx[dados$cons.conf.idx == -21] <- -0.8077
dados$cons.conf.idx[dados$cons.conf.idx == -22] <- -0.8462
dados$cons.conf.idx[dados$cons.conf.idx == -23] <- -0.8846
dados$cons.conf.idx[dados$cons.conf.idx == -24] <- -0.9231
dados$cons.conf.idx[dados$cons.conf.idx == -25] <- -0.9615
dados$cons.conf.idx[dados$cons.conf.idx == -26] <- -1.0000

#dados$euribor3m <- as.double(discretize(dados$euribor3m,method = "cluster",breaks = 5, labels=c(0.1,0.2,0.3,0.4,0.5)))

#dados$euribor3m[dados$cons.conf.idx == 1] <- 0.1



#View(dados$pdays)





#dividir dados em treino e teste
treino <- (dados[1:3000,])
teste <- (dados[3001:4119,])

#defini????o das camadas de entrada e sa??da da RNA
funcao <- y ~ age+job+marital+education+default+housing+loan+campaign+pdays+previous+poutcome+emp.var.rate+cons.price.idx+cons.conf.idx

#form1 <- y ~ pdays + cons.conf.idx + euribor3m + cons.price.idx + emp.var.rate + poutcome 

form2 <- y ~ job + marital + education + default + housing + loan + pdays + previous

#sel <- regsubsets(form3,dados,nvmax=16)
#summary(sel)

rede <- neuralnet(funcao, treino,hidden= c(4), lifesign = "full", linear.output = FALSE, threshold = 0.01)

teste3 <-subset(teste,select=c("age","job","marital","education","default","housing", "loan","campaign","pdays","previous","poutcome","emp.var.rate","cons.price.idx","cons.conf.idx"))

rede.resultados <- compute(rede,teste3)

resultadosRede <- data.frame(atual=teste$y,
                             previsao=rede.resultados$net.result)

rmse(c(teste$y),c(resultadosRede$previsao))

plot(rede)


rede2 <- neuralnet(form2, treino,hidden= c(4,2), lifesign = "full", linear.output = FALSE, threshold = 0.01)

teste3 <-subset(teste,select=c("job","marital","education","default","housing", "loan","pdays","previous"))

rede2.resultados <- compute(rede2,teste3)

resultadosRede <- data.frame(atual=teste$y,
                             previsao=rede2.resultados$net.result)

rmse(c(teste$y),c(resultadosRede$previsao))

plot(rede2)

#PAROU AQUI
###################




















rede <- neuralnet(form1, treino, hidden = c(4), lifesign = "full",linear.output = FALSE, threshold = 0.1)


#random
#m??dia entre neur??nios de entrada e sa??da
ex <- neuralnet(funcao, treino, hidden = c(4,2), lifesign = "full",linear.output = FALSE, threshold = 0.1)


rede2 <- neuralnet(form2, treino, hidden = c(4,2), lifesign = "full",linear.output = FALSE, threshold = 0.1, algorithm = "slr")

rede3 <- neuralnet(form2, treino, hidden = c(4,2), lifesign = "full",linear.output = FALSE, threshold = 0.1, algorithm = "sag")

rede4 <- neuralnet(form2, treino, hidden = c(4,2), lifesign = "full",linear.output = FALSE, threshold = 0.1, algorithm = "backprop",learningrate = 0.0001)

rede5 <- neuralnet(form2, treino, hidden = c(4,2), lifesign = "full",linear.output = FALSE, threshold = 0.1, algorithm = "rprop-")

#mostra a rede

#subset para teste 

teste3 <-subset(teste,select=c("job","education","default","pdays","previous"))
                                 
                                 
teste1 <-subset(teste,select=c("age","job","marital","education","default","housing","loan","campaign","pdays","previous","poutcome","emp.var.rate","cons.price.idx","cons.conf.idx","euribor3m"))

teste2 <-subset(teste,select=c("pdays","cons.conf.idx","euribor3m","cons.price.idx","emp.var.rate","poutcome"))

#teste3 <- subset(teste,select=c("pdays","cons.conf.idx","euribor3m","cons.price.idx","emp.var.rate","poutcome"))

rede.resultados <- compute(rede,teste3)



#ex.resultados <- compute(ex,teste1)

#rede2.resultados <- compute(rede2,teste3)


#resultadosEx <- data.frame(atual=teste$y,
                         #previsao=ex.resultados$net.result)


resultadosRede <- data.frame(atual=teste$y,
                           previsao=rede.resultados$net.result)

#resultadosRede2 <- data.frame(atual=teste$y,
 #                            previsao=rede2.resultados$net.result)

#calcular o RMSE(Root Mean Square Error)

rmse(c(teste$y),c(resultadosRede$previsao))

#rmse(c(teste$y),c(resultadosEx$previsao))
#rmse(c(teste$y),c(resultadosRede2$previsao))

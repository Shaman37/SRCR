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
dados <- read.csv(file="bank-additional-full3.csv", header=TRUE, sep=",")


#not working
#dados$pdays <-  as.numeric(discretize(dados$pdays, method = "frequency", breaks = 10))

dados$age <- as.double(discretize(dados$age,method = "cluster",breaks = 5, labels = c(1,2,3,4,5)))


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


dados$housing <- as.double(discretize(dados$housing,method="cluster",breaks =3, labels = c(0.1,0.2,0.3)))

dados$housing[dados$housing == 1] <- 0.333333
dados$housing[dados$housing == 2] <- 0.666666
dados$housing[dados$housing == 3] <- 0.999999


dados$loan <- as.double(discretize(dados$loan,method="cluster",breaks =3, labels = c(0.1,0.2,0.3)))

dados$loan[dados$loan == 1] <- 0.333333
dados$loan[dados$loan == 2] <- 0.666666
dados$loan[dados$loan == 3] <- 0.999999


#dados$campaign <- as.double(discretize(dados$campaign,method="cluster",breaks =45, labels = c(0:4,5)))

dados$pdays <- as.double(discretize(dados$pdays,method = "cluster",breaks = 22, labels=c(0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.1,1.2,1.3,1.4,1.5,1.6,1.7,1.8,1.9,2.0,2.1,2.2,2.3,2.4,2.5,2.6,2.7)))

dados$pdays[dados$pdays == 1] <- 0.037
dados$pdays[dados$pdays == 2] <- 0.074
dados$pdays[dados$pdays == 3] <- 0.111
dados$pdays[dados$pdays == 4] <- 0.148
dados$pdays[dados$pdays == 5] <- 0.222
dados$pdays[dados$pdays == 6] <- 0.259
dados$pdays[dados$pdays == 7] <- 0.296
dados$pdays[dados$pdays == 8] <- 0.333
dados$pdays[dados$pdays == 9] <- 0.37
dados$pdays[dados$pdays == 10] <- 0.407
dados$pdays[dados$pdays == 11] <- 0.444
dados$pdays[dados$pdays == 12] <- 0.481
dados$pdays[dados$pdays == 13] <- 0.518
dados$pdays[dados$pdays == 14] <- 0.555
dados$pdays[dados$pdays == 15] <- 0.592
dados$pdays[dados$pdays == 16] <- 0.629
dados$pdays[dados$pdays == 17] <- 0.666
dados$pdays[dados$pdays == 18] <- 0.703
dados$pdays[dados$pdays == 19] <- 0.74
dados$pdays[dados$pdays == 20] <- 0.777
dados$pdays[dados$pdays == 21] <- 0.814
dados$pdays[dados$pdays == 22] <- 0.851

dados$previous <- as.double(discretize(dados$previous,method = "cluster",breaks = 8, labels=c(0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8)))

dados$previous[dados$previous == 1] <- 0.125
dados$previous[dados$previous == 2] <- 0.250
dados$previous[dados$previous == 3] <- 0.375
dados$previous[dados$previous == 4] <- 0.500
dados$previous[dados$previous == 5] <- 0.625
dados$previous[dados$previous == 6] <- 0.75
dados$previous[dados$previous == 7] <- 0.875
dados$previous[dados$previous == 8] <- 1


#dados$poutcome<- as.double(discretize(dados$poutcome,method = "cluster",breaks = 3, labels=c(c(-0.6,-0.5,-0.4,-0.3,-0.2,-0.1,0.1,0.2))))

#dados$poutcome[dados$poutcome == 1] <- 0.33333
#dados$poutcome[dados$poutcome == 2] <- 0.66666
#dados$poutcome[dados$poutcome == 3] <- 0.99999

#dados$emp.var.rate<- as.double(discretize(dados$emp.var.rate,method = "cluster",breaks = 9, labels=c(0.1,0.2,0.3,0.4,0.5)))




#dados$cons.conf.idx <- as.double(discretize(dados$cons.conf.idx,method = "cluster",breaks = 5, labels=c(0.1,0.2,0.3,0.4,0.5)))

#dados$cons.conf.idx[dados$cons.conf.idx == 1] <- 0.1
#dados$cons.conf.idx[dados$cons.conf.idx == 2] <- 0.2
#dados$cons.conf.idx[dados$cons.conf.idx == 3] <- 0.3
#dados$cons.conf.idx[dados$cons.conf.idx == 4] <- 0.4
#dados$cons.conf.idx[dados$cons.conf.idx == 5] <- 0.5

#dados$euribor3m <- as.double(discretize(dados$euribor3m,method = "cluster",breaks = 5, labels=c(0.1,0.2,0.3,0.4,0.5)))

#dados$euribor3m[dados$cons.conf.idx == 1] <- 0.1
#dados$cons.conf.idx[dados$cons.conf.idx == 2] <- 0.2
#dados$cons.conf.idx[dados$cons.conf.idx == 3] <- 0.3
#dados$cons.conf.idx[dados$cons.conf.idx == 4] <- 0.4
#dados$cons.conf.idx[dados$cons.conf.idx == 5] <- 0.5

#dados$cons.price.idx<- as.double(discretize(dados$cons.price.idx,method = "cluster",breaks = 5, labels=c(0.1,0.2,0.3,0.4,0.5)))



#View(dados$pdays)





#dividir dados em treino e teste
treino <- (dados[1:3000,])
teste <- (dados[3001:4521,])

#defini????o das camadas de entrada e sa??da da RNA
#funcao <- y ~ age+job+marital+education+default+housing+loan+campaign+pdays+previous+poutcome+emp.var.rate+cons.price.idx+cons.conf.idx+euribor3m

#form1 <- y ~ pdays + cons.conf.idx + euribor3m + cons.price.idx + emp.var.rate + poutcome 

form2 <- y ~ job + marital + education + default + housing + loan + pdays + previous

#form3 <- y ~ age+ marital+job+education+default+pdays+previous

#sel <- regsubsets(form3,dados,nvmax=16)
#summary(sel)

rede <- neuralnet(form2, treino,hidden= c(4), lifesign = "full", linear.output = FALSE, threshold = 0.05)

teste3 <-subset(teste,select=c("job","marital","education","default","housing", "loan", "pdays","previous"))

rede.resultados <- compute(rede,teste3)

resultadosRede <- data.frame(atual=teste$y,
                             previsao=rede.resultados$net.result)

rmse(c(teste$y),c(resultadosRede$previsao))

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

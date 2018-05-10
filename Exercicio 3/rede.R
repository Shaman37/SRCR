#libs
set.seed(1234567890)
library(neuralnet)
library(hydroGOF)
library(leaps)
library(arules)

#carregar ficheiro
dados <- read.csv(file="//home/yoda45/Desktop/SRCR/bank-additional-full1.csv", header=TRUE, sep=",")

#not working
#dados$pdays <-  as.numeric(discretize(dados$pdays, method = "frequency", breaks = 10))

dados$pdays <- discretize(dados$pdays,method = "cluster",breaks = 5, labels=c(0.1,0.2,0.3,0.4,0.5))

#dividir dados em treino e teste
treino <- (dados[1:30000,])
teste <- (dados[30001:41188,])

#definição das camadas de entrada e saída da RNA
funcao <- y ~ age+job+marital+education+default+housing+loan+campaign+pdays+previous+poutcome+emp.var.rate+cons.price.idx+cons.conf.idx+euribor3m

form1 <- y ~ pdays + cons.conf.idx + euribor3m + cons.price.idx + emp.var.rate + poutcome

sel <- regsubsets(funcao,dados,nvmax=16)
summary(sel)




#random
#média entre neurónios de entrada e saída
ex <- neuralnet(funcao, treino, hidden = c(4), lifesign = "full",linear.output = FALSE, threshold = 0.1)

rede <- neuralnet(form1, treino, hidden = c(4), lifesign = "full",linear.output = FALSE, threshold = 0.1)


#mostra a rede
plot(ex,rep = "best")

#subset para teste 
teste1 <-subset(teste,select=c("age","job","marital","education","default","housing","loan","campaign","pdays","previous","poutcome","emp.var.rate","cons.price.idx","cons.conf.idx","euribor3m"))

teste2 <-subset(teste,select=c("pdays","cons.conf.idx","euribor3m","cons.price.idx","emp.var.rate","poutcome"))

rede.resultados <- compute(rede,teste2)



resultados <- data.frame(atual=teste$y,
                         previsao=rede.resultados$net.result)

#calcular o RMSE(Root Mean Square Error)
rmse(c(teste$y),c(resultados$previsao))

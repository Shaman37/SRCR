#libs
set.seed(1234567890)
library(neuralnet)
library(hydroGOF)
library(leaps)
library(arules)

#mudar diretoria para o projeto
setwd("/Users/josesousa/Documents/SRCR/Exercicio\ 3")
#setwd(/home/yoda45/Desktop/SRCR)

#carregar ficheiro
dados <- read.csv(file="bank.csv", header=TRUE, sep=",")

#not working
dados$pdays <-  as.numeric(discretize(dados$pdays, method = "frequency", breaks = 10))

#dividir dados em treino e teste
treino <- (dados[1:30000,])
teste <- (dados[30001:41188,])

#defini????o das camadas de entrada e sa??da da RNA
funcao <- y ~ age+job+marital+education+default+housing+loan+campaign+pdays+previous+poutcome+emp.var.rate+cons.price.idx+cons.conf.idx+euribor3m

form1 <- y ~ pdays + cons.conf.idx + euribor3m + cons.price.idx + emp.var.rate + poutcome 

#sel <- regsubsets(funcao,dados,nvmax=16)
#summary(sel)




#random
#m??dia entre neur??nios de entrada e sa??da
ex <- neuralnet(funcao, treino, hidden = c(4,2), lifesign = "full",linear.output = FALSE, threshold = 0.1)

rede <- neuralnet(form1, treino, hidden = c(4,2), lifesign = "full",linear.output = FALSE, threshold = 0.1)

rede2 <- neuralnet(form2, treino, hidden = c(4,2), lifesign = "full",linear.output = FALSE, threshold = 0.1, algorithm = "slr")

rede3 <- neuralnet(form2, treino, hidden = c(4,2), lifesign = "full",linear.output = FALSE, threshold = 0.1, algorithm = "sag")

rede4 <- neuralnet(form2, treino, hidden = c(4,2), lifesign = "full",linear.output = FALSE, threshold = 0.1, algorithm = "backprop",learningrate = 0.0001)

rede5 <- neuralnet(form2, treino, hidden = c(4,2), lifesign = "full",linear.output = FALSE, threshold = 0.1, algorithm = "rprop-")

#mostra a rede

#subset para teste 
teste1 <-subset(teste,select=c("age","job","marital","education","default","housing","loan","campaign","pdays","previous","poutcome","emp.var.rate","cons.price.idx","cons.conf.idx","euribor3m"))

teste2 <-subset(teste,select=c("pdays","cons.conf.idx","euribor3m","cons.price.idx","emp.var.rate","poutcome"))

teste3 <- subset(teste,select=c("pdays","cons.conf.idx","euribor3m","cons.price.idx","emp.var.rate","poutcome"))

rede.resultados <- compute(rede,teste2)
ex.resultados <- compute(ex,teste1)
rede2.resultados <- compute(rede2,teste3)


resultadosEx <- data.frame(atual=teste$y,
                         previsao=ex.resultados$net.result)


resultadosRede <- data.frame(atual=teste$y,
                           previsao=rede.resultados$net.result)

resultadosRede2 <- data.frame(atual=teste$y,
                             previsao=rede2.resultados$net.result)

#calcular o RMSE(Root Mean Square Error)
rmse(c(teste$y),c(resultadosRede$previsao))
rmse(c(teste$y),c(resultadosEx$previsao))
rmse(c(teste$y),c(resultadosRede2$previsao))

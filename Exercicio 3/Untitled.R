set.seed(1234567890)
library(neuralnet)
library(hydroGOF)
library(leaps)
library(arules)

dados <- read.csv(file="/Users/josesousa/Documents/SRCR/Exercicio/bank.csv",header=TRUE,sep=",")


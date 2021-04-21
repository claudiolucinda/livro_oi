#########################################
# Código Nerlove
# Estimação Função Custos
# Claudio R. Lucinda
# 2021
#########################################

#install.packages("readxl")

library(tidyverse)
library(readxl)
library(car)

rm(list=ls())

data=read_xls("NerloveDta.xls",skip=1)

# Modelo 01 - Cobb-Douglas (sem Retornos Constantes de escala)

lm_log.model=lm(log1p(TC)~log1p(Q)+log1p(PF)+log1p(PK)+log1p(PL), data=data)
summary(lm_log.model)

# Testando a hipótese de RCE

linearHypothesis(lm_log.model,"log1p(PF)+log1p(PK)+log1p(PL)=1")

#Não posso rejeitar a hipótese

# Modelo restrito
lm_log.rest=lm(log1p(TC/PL)~offset(log1p(Q))+log1p(PK/PL)+log1p(PF/PL), data=data)
summary(lm_log.rest)


alpha_L<-1-coef(lm_log.rest)[2]-coef(lm_log.rest)[3]
D <- c(0, -1, -1)
alpha_L.se <- sqrt( t(D) %*% vcov(lm_log.rest) %*% D)
alpha_L
alpha_L.se

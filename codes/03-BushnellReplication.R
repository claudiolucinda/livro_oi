#############################################################
# Código para estimar a Demanda Residual
# Claudio R. Lucinda
# Adaptado dos Arquivos de Replicação de Bushnell et. al.
# AER Paper
# 2021-04-05
############################################################

library(tidyverse)
library(dplyr)
library(AER)
library(readstata13)
library(haven)

rm(list=ls())
dataCAL=read_dta(file="./codes/california.dta")

dataCAL=dataCAL %>%
  filter(DATE>19990600 & DATE<19991000) %>%
  mutate(peak=ifelse(HOUR>10 & HOUR<21,ifelse(SAT==1 | SUN==1,0,1),0)) %>%
  rename(fringe=Q_frg, price=lnp, load=lnI)

weather_names=c(colnames(dataCAL)[5:24], colnames(dataCAL)[125:182], colnames(dataCAL)[233:310], 
       colnames(dataCAL)[202:207], colnames(dataCAL)[208:230],colnames(dataCAL)[196:199])

weather=paste(weather_names, collapse="+")

spec=as.formula(paste("fringe~price+",weather,"| load+", weather, collapse=""))

model01=ivreg(spec, data=dataCAL)
summary(model01)

dataCAL$E=model01$residuals
dataCAL = dataCAL %>%
  arrange(T) %>%
  mutate(El=lag(E))

model02=lm(E~-1+El, data=dataCAL)

rho=model02$coefficients[1]

DdataCAL=dataCAL

listvars=c("fringe","price","load",weather_names)

quasidiff = function(x) (x-rho*lag(x))

DdataCAL = DdataCAL %>%
  mutate_at(listvars, quasidiff)

model03=ivreg(spec, data=DdataCAL)

# Agora só falta avaliar a elasticidade-preço da demanda residual

dataCAL = dataCAL %>%
  mutate(resdem=exp(load)-fringe)

mval=mean(dataCAL$resdem, na.rm=TRUE)

elast=-model03$coefficients[2]/mval
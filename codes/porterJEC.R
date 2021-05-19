############################################
# Porter's JEC paper Replication
# Claudio R. Lucinda
# 2021
# FEA/USP
############################################

library(readstata13)
library(tidyverse)
library(AER)
library(ggplot2)

rm(list=ls())

data=read.delim("./codes/porter.out", sep="\t")

data = data %>%
  mutate(logq=log(tqg), logp=log(gr), po_price=po*logp, lakes_dm1=lakes*dm1,
         lakes_dm2=lakes*dm2, lakes_dm3=lakes*dm3, lakes_dm4=lakes*dm4,
         lakes_po=lakes*po)

ggplot(data, aes(x=week, y=gr)) +
  geom_line()

# Supply and Demand

demand=ivreg(logq~logp+lakes+t1+t2+t3+t4+t5+t6+t7+t8+t9+t10+t11+t12 |
               dm1+dm2+dm3+dm4+po+lakes+t1+t2+t3+t4+t5+t6+t7+t8+t9+t10+t11+t12, data=data)

summary(demand)

supply=ivreg(logp~logq+dm1+dm2+dm3+dm4+po+t1+t2+t3+t4+t5+t6+t7+t8+t9+t10+t11+t12 |
               lakes++dm1+dm2+dm3+dm4+po+t1+t2+t3+t4+t5+t6+t7+t8+t9+t10+t11+t12, data=data)

summary(supply)

# Interaction Model

inter=ivreg(logq~logp+po_price+lakes+t1+t2+t3+t4+t5+t6+t7+t8+t9+t10+t11+t12 |
              dm1+dm2+dm3+dm4+po+lakes+t1+t2+t3+t4+t5+t6+t7+t8+t9+t10+t11+t12+lakes_po, data=data)

summary(inter)
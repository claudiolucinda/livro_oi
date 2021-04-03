########################################################
# Wolak
# Curva de Demanda Residual
# Claudio R. Lucinda
# 2021
########################################################

library(tidyverse)
library(readxl)
library(car)

rm(list=ls())


data=read.csv("./WolakData/BBW_Archive.dat", col.names = c("Year", "Month", "Day", "Hour", "Price", "Quantity"), stringsAsFactors = FALSE)
data$Price=as.numeric(data$Price)
data$Year=as.numeric(data$Year)

data_STATA=readstata13::read.dta13("./WolakData/BBW_Archive.dta")

data_Excel=readxl::read_excel("./WolakData/BBW_Archive.xls", 
                              sheet = "Gen Unit Info", skip =3,
                              col_names = c("UNIT NAME","RES_ID","OWNER",
                                            "MW","NERC_EAF","NERC_SOF", 
                                            "NERC_FOF", "O_M", "Rate", "Type"))
data_Excel=data_Excel[-93,]

data_MW_Producer=data_Excel %>%
  group_by(OWNER) %>%
  summarise(capacity=sum(MW)) %>%
  arrange(desc(capacity))


data_STATA=data_STATA %>%
  rename(Year=year, Month=month, Day=day, Hour=hour) %>%
  mutate(DR1=Q_MT-Q_imp-Qinstate+data_MW_Producer$capacity[1],
         DR2=Q_MT-Q_imp-Qinstate+data_MW_Producer$capacity[2],
         DR3=Q_MT-Q_imp-Qinstate+data_MW_Producer$capacity[3],
         DR4=Q_MT-Q_imp-Qinstate+data_MW_Producer$capacity[4]) %>%
  arrange(Year, Month, Day, Hour, pxp)


data_1998_CAL = data_STATA %>%
  rename(Year=year, Month=month, Day=day, Hour=hour) %>%
  filter(Year==1998, Month>5 & Month<10) %>%
  select(Year, Month, Day, Hour, Qinstate)

data_1999_CAL = data_STATA %>%
  rename(Year=year, Month=month, Day=day, Hour=hour) %>%
  filter(Year==1999, Month>5 & Month<10)%>%
  select(Year, Month, Day, Hour, Qinstate)

data_2000_CAL = data_STATA %>%
  rename(Year=year, Month=month, Day=day, Hour=hour, Price=pxp) %>%
  filter(Year==2000, Month>5 & Month<10)%>%
  select(Year, Month, Day, Hour, Qinstate)

data_1998=data%>%
  filter(Year==1998, Month>5 & Month<10) %>%
  group_by(Year, Month, Day, Hour) 

data_1999=data%>%
  filter(Year==1999, Month>5 & Month<10) %>%
  group_by(Year, Month, Day, Hour)

data_2000=data%>%
  filter(Year==2000, Month>5 & Month<10) %>%
  group_by(Year, Month, Day, Hour)

teste_1998=data_1998_CAL %>%
  left_join(data_1998, by=c("Year","Month","Day","Hour")) %>%
  filter(Price>20) %>%
  mutate(Q1=Quantity-Qinstate+data_MW_Producer$capacity[1],
         Q2=Quantity-Qinstate+data_MW_Producer$capacity[2],
         Q3=Quantity-Qinstate+data_MW_Producer$capacity[3],
         Q4=Quantity-Qinstate+data_MW_Producer$capacity[4]) %>%
  mutate(PH=lead(Price), 
         Q1H=lead(Q1), 
         Q2H=lead(Q2), 
         Q3H=lead(Q3), 
         Q4H=lead(Q4), 
         PL=lag(Price), 
         Q1L=lag(Q1),
         Q2L=lag(Q2),
         Q3L=lag(Q3),
         Q4L=lag(Q4)) %>%
  mutate(arcelast1=((Q1H-Q1L)/(PH-PL))*((PH+PL)/(Q1H+Q1L)),
         arcelast2=((Q2H-Q2L)/(PH-PL))*((PH+PL)/(Q2H+Q2L)),
         arcelast3=((Q3H-Q3L)/(PH-PL))*((PH+PL)/(Q3H+Q3L)),
         arcelast4=((Q4H-Q4L)/(PH-PL))*((PH+PL)/(Q4H+Q4L))) 
summary(teste_1998$arcelast1)
summary(teste_1998$arcelast2)
summary(teste_1998$arcelast3)
summary(teste_1998$arcelast4)


teste_1999=data_1999_CAL %>%
  left_join(data_1999, by=c("Year","Month","Day","Hour")) %>%
  filter(Price>20) %>%
  mutate(Q1=Quantity-Qinstate+data_MW_Producer$capacity[1],
         Q2=Quantity-Qinstate+data_MW_Producer$capacity[2],
         Q3=Quantity-Qinstate+data_MW_Producer$capacity[3],
         Q4=Quantity-Qinstate+data_MW_Producer$capacity[4]) %>%
  mutate(PH=lead(Price), 
         Q1H=lead(Q1), 
         Q2H=lead(Q2), 
         Q3H=lead(Q3), 
         Q4H=lead(Q4), 
         PL=lag(Price), 
         Q1L=lag(Q1),
         Q2L=lag(Q2),
         Q3L=lag(Q3),
         Q4L=lag(Q4)) %>%
  mutate(arcelast1=((Q1H-Q1L)/(PH-PL))*((PH+PL)/(Q1H+Q1L)),
         arcelast2=((Q2H-Q2L)/(PH-PL))*((PH+PL)/(Q2H+Q2L)),
         arcelast3=((Q3H-Q3L)/(PH-PL))*((PH+PL)/(Q3H+Q3L)),
         arcelast4=((Q4H-Q4L)/(PH-PL))*((PH+PL)/(Q4H+Q4L))) 
summary(teste_1999$arcelast1)
summary(teste_1999$arcelast2)
summary(teste_1999$arcelast3)
summary(teste_1999$arcelast4)

teste_2000=data_2000_CAL %>%
  left_join(data_2000, by=c("Year","Month","Day","Hour")) %>%
  filter(Price>20) %>%
  mutate(Q1=Quantity-Qinstate+data_MW_Producer$capacity[1],
         Q2=Quantity-Qinstate+data_MW_Producer$capacity[2],
         Q3=Quantity-Qinstate+data_MW_Producer$capacity[3],
         Q4=Quantity-Qinstate+data_MW_Producer$capacity[4]) %>%
  mutate(PH=lead(Price), 
         Q1H=lead(Q1), 
         Q2H=lead(Q2), 
         Q3H=lead(Q3), 
         Q4H=lead(Q4), 
         PL=lag(Price), 
         Q1L=lag(Q1),
         Q2L=lag(Q2),
         Q3L=lag(Q3),
         Q4L=lag(Q4)) %>%
  mutate(arcelast1=((Q1H-Q1L)/(PH-PL))*((PH+PL)/(Q1H+Q1L)),
         arcelast2=((Q2H-Q2L)/(PH-PL))*((PH+PL)/(Q2H+Q2L)),
         arcelast3=((Q3H-Q3L)/(PH-PL))*((PH+PL)/(Q3H+Q3L)),
         arcelast4=((Q4H-Q4L)/(PH-PL))*((PH+PL)/(Q4H+Q4L))) 
summary(teste_2000$arcelast1)
summary(teste_2000$arcelast2)
summary(teste_2000$arcelast3)
summary(teste_2000$arcelast4)


# data_2000=data%>%
#   filter(Year==2000, Month>5 & Month<10, Price>20) %>%
#   group_by(Year, Month, Day, Hour) %>%
#   mutate(PH=lead(Price), QH=lead(Quantity), PL=lag(Price), QL=lag(Quantity)) %>%
#   mutate(arcelast=((QH-QL)/(PH-PL))*((PH+PL)/(QH+QL)))
# summary(data_2000$arcelast)


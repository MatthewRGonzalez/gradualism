#This is the test code for cleaning the excel data

rm(list = ls())# clear all

library(tidyverse)
library(foreign)
library(dplyr)
library(readr)
library(tidyselect)

# setwd("C:/Users/victo/OneDrive/桌面/code for gradualism")#Set working directory

# file is saved as csv "UTF-8" and thus needs encoding to avoid garbled
# It appears that during the transformation to CSV file, some cells contain "space" or invisible dots which could be easily taken as empty, and they are not. Also since the "fill" function is applicable iff the cases are NA but not empty. Replace them all by NA.

# Select the desired columns from the csv by names
data_set <- read.csv(file='C:/Users/krist/Downloads/test_1.csv', encoding="UTF-8",na.string=c(""," ","" ,"" ,"NA","\u00A0"))[,c('X.U.FEFF.Schedule','Paragraph','Description','Specific_SH','Units_SH','Ad_Valorem_SH','Specific_Geneva',
                                                                'Units_Geneva','Ad_Valorem_Geneva','Specific_Annecy','Units_Annecy','Ad_Valorem_Annecy','Specific_Torquay','Units_Torquay','Ad_Valorem_Torquay',
                                                                  'Specific_Geneva56_A','Units_Geneva56_A','Ad_Valorem_Geneva56_A','Specific_Geneva56_B','Units_Geneva56_B','Ad_Valorem_Geneva56_B',
                                                                'Specific_Geneva56_C','Units_Geneva56_C','Ad_Valorem_Geneva56_C','Specific_Dillon_A','Units_Dillon_A','Ad_Valorem_Dillon_A',
                                                                'Specific_Dillon_B','Units_Dillon_B','Ad_Valorem_Dillon_B','Interval')]


# Fill the paragraph and schedule numbers in
data_set<-fill(data_set, X.U.FEFF.Schedule, .direction="down")
data_set<-fill(data_set, Paragraph, .direction="down")

# Create product number so that every line can be located as, "Paragraph X, Product Y". Note the schedule information is contained in the paragraph number. 'id' is just a running count throught the full data set.
data_set<-data_set %>%
  mutate(id=row_number()) %>%
  group_by(Paragraph) %>%
  mutate(Product=row_number()) %>% ungroup()



###############################################################################
### Fill the empty cases by rounds
###############################################################################


# Fill the empty cases. Logic: if it is NA, take the same value as the previous rounds, notice that NA will still be NA if this product does not have this tax rate.
#### Potential risk warning #### It does create confusion if the form of tax changed over time, say from ad_valorem to specific. Requires an "if" structure that the tax rate of this product
# are  all NA. I solve this problem by also conditioning on that both specific and Ad_valorem tax rate are NA.



# Fill up the specific tax rate by order. Notice that the order is important. 
data_set$Specific_Geneva[which(is.na(data_set$Specific_Geneva) & is.na(data_set$Ad_Valorem_Geneva),arr.ind = TRUE)]<- # SH to Geneva "Specific" 
  data_set$Specific_SH[which(is.na(data_set$Specific_Geneva) & is.na(data_set$Ad_Valorem_Geneva),arr.ind = TRUE)]

data_set$Specific_Annecy[which(is.na(data_set$Specific_Annecy) & is.na(data_set$Ad_Valorem_Annecy),arr.ind = TRUE)]<- # Geneva to Annecy "Specific" 
  data_set$Specific_Geneva[which(is.na(data_set$Specific_Annecy) & is.na(data_set$Ad_Valorem_Annecy),arr.ind = TRUE)]

data_set$Specific_Torquay[which(is.na(data_set$Specific_Torquay) & is.na(data_set$Ad_Valorem_Torquay),arr.ind = TRUE)]<- # Annecy to Torquay "Specific" 
  data_set$Specific_Annecy[which(is.na(data_set$Specific_Torquay) & is.na(data_set$Ad_Valorem_Torquay),arr.ind = TRUE)]

data_set$Specific_Geneva56_A[which(is.na(data_set$Specific_Geneva56_A) & is.na(data_set$Ad_Valorem_Geneva56_A),arr.ind = TRUE)]<- # Torquay to Geneva_A "Specific" 
  data_set$Specific_Torquay[which(is.na(data_set$Specific_Geneva56_A) & is.na(data_set$Ad_Valorem_Geneva56_A),arr.ind = TRUE)]

data_set$Specific_Geneva56_B[which(is.na(data_set$Specific_Geneva56_B) & is.na(data_set$Ad_Valorem_Geneva56_B),arr.ind = TRUE)]<- # Geneva_A to Geneva_B "Specific" 
  data_set$Specific_Geneva56_A[which(is.na(data_set$Specific_Geneva56_B) & is.na(data_set$Ad_Valorem_Geneva56_B),arr.ind = TRUE)]

data_set$Specific_Geneva56_C[which(is.na(data_set$Specific_Geneva56_C) & is.na(data_set$Ad_Valorem_Geneva56_C),arr.ind = TRUE)]<- # Geneva_B to Geneva_C "Specific" 
  data_set$Specific_Geneva56_B[which(is.na(data_set$Specific_Geneva56_C) & is.na(data_set$Ad_Valorem_Geneva56_C),arr.ind = TRUE)]

data_set$Specific_Dillon_A[which(is.na(data_set$Specific_Dillon_A) & is.na(data_set$Ad_Valorem_Dillon_A),arr.ind = TRUE)]<- # Geneva_C to Dillon_A "Specific" 
  data_set$Specific_Geneva56_C[which(is.na(data_set$Specific_Dillon_A) & is.na(data_set$Ad_Valorem_Dillon_A),arr.ind = TRUE)]

data_set$Specific_Dillon_B[which(is.na(data_set$Specific_Dillon_B) & is.na(data_set$Ad_Valorem_Dillon_B),arr.ind = TRUE)]<- # Dillon_A to Dillon_B "Specific" 
  data_set$Specific_Dillon_A[which(is.na(data_set$Specific_Dillon_B) & is.na(data_set$Ad_Valorem_Dillon_B),arr.ind = TRUE)]


# Fill up the Unit by order. Notice that the order is important.
data_set$Units_Geneva[which(is.na(data_set$Specific_Geneva) & is.na(data_set$Ad_Valorem_Geneva),arr.ind = TRUE)]<- # SH to Geneva "Units" 
  data_set$Units_SH[which(is.na(data_set$Specific_Geneva) & is.na(data_set$Ad_Valorem_Geneva),arr.ind = TRUE)]

data_set$Units_Annecy[which(is.na(data_set$Specific_Annecy) & is.na(data_set$Ad_Valorem_Annecy),arr.ind = TRUE)]<- # Geneva to Annecy "Units" 
  data_set$Units_Geneva[which(is.na(data_set$Specific_Annecy) & is.na(data_set$Ad_Valorem_Annecy),arr.ind = TRUE)]

data_set$Units_Torquay[which(is.na(data_set$Specific_Torquay) & is.na(data_set$Ad_Valorem_Torquay),arr.ind = TRUE)]<- # Annecy to Torquay "Units" 
  data_set$Units_Annecy[which(is.na(data_set$Specific_Torquay) & is.na(data_set$Ad_Valorem_Torquay),arr.ind = TRUE)]

data_set$Units_Geneva56_A[which(is.na(data_set$Specific_Geneva56_A) & is.na(data_set$Ad_Valorem_Geneva56_A),arr.ind = TRUE)]<- # Torquay to Geneva_A "Units" 
  data_set$Units_Torquay[which(is.na(data_set$Specific_Geneva56_A) & is.na(data_set$Ad_Valorem_Geneva56_A),arr.ind = TRUE)]

data_set$Units_Geneva56_B[which(is.na(data_set$Specific_Geneva56_B) & is.na(data_set$Ad_Valorem_Geneva56_B),arr.ind = TRUE)]<- # Geneva_A to Geneva_B "Units" 
  data_set$Units_Geneva56_A[which(is.na(data_set$Specific_Geneva56_B) & is.na(data_set$Ad_Valorem_Geneva56_B),arr.ind = TRUE)]

data_set$Units_Geneva56_C[which(is.na(data_set$Specific_Geneva56_C) & is.na(data_set$Ad_Valorem_Geneva56_C),arr.ind = TRUE)]<- # Geneva_B to Geneva_C "Units" 
  data_set$Units_Geneva56_B[which(is.na(data_set$Specific_Geneva56_C) & is.na(data_set$Ad_Valorem_Geneva56_C),arr.ind = TRUE)]

data_set$Units_Dillon_A[which(is.na(data_set$Specific_Dillon_A) & is.na(data_set$Ad_Valorem_Dillon_A),arr.ind = TRUE)]<- # Geneva_C to Dillon_A "Units" 
  data_set$Units_Geneva56_C[which(is.na(data_set$Specific_Dillon_A) & is.na(data_set$Ad_Valorem_Dillon_A),arr.ind = TRUE)]

data_set$Units_Dillon_B[which(is.na(data_set$Specific_Dillon_B) & is.na(data_set$Ad_Valorem_Dillon_B),arr.ind = TRUE)]<- # Dillon_A to Dillon_B "Units" 
  data_set$Units_Dillon_A[which(is.na(data_set$Specific_Dillon_B) & is.na(data_set$Ad_Valorem_Dillon_B),arr.ind = TRUE)]


# Fill up the Ad_valorem tax rate by order. Notice that the order is important.
data_set$Ad_Valorem_Geneva[which(is.na(data_set$Specific_Geneva) & is.na(data_set$Ad_Valorem_Geneva),arr.ind = TRUE)]<- # SH to Geneva Ad_Valorem 
  data_set$Ad_Valorem_SH[which(is.na(data_set$Specific_Geneva) & is.na(data_set$Ad_Valorem_Geneva),arr.ind = TRUE)]

data_set$Ad_Valorem_Annecy[which(is.na(data_set$Specific_Annecy) & is.na(data_set$Ad_Valorem_Annecy),arr.ind = TRUE)]<- # Geneva to Annecy Ad_Valorem
  data_set$Ad_Valorem_Geneva[which(is.na(data_set$Specific_Annecy) & is.na(data_set$Ad_Valorem_Annecy),arr.ind = TRUE)]

data_set$Ad_Valorem_Torquay[which(is.na(data_set$Specific_Torquay) & is.na(data_set$Ad_Valorem_Torquay),arr.ind = TRUE)]<- # Annecy to Torquay Ad_Valorem
  data_set$Ad_Valorem_Annecy[which(is.na(data_set$Specific_Torquay) & is.na(data_set$Ad_Valorem_Torquay),arr.ind = TRUE)]

data_set$Ad_Valorem_Geneva56_A[which(is.na(data_set$Specific_Geneva56_A) & is.na(data_set$Ad_Valorem_Geneva56_A),arr.ind = TRUE)]<- # Torquay to Geneva_A Ad_Valorem
  data_set$Ad_Valorem_Torquay[which(is.na(data_set$Specific_Geneva56_A) & is.na(data_set$Ad_Valorem_Geneva56_A),arr.ind = TRUE)]

data_set$Ad_Valorem_Geneva56_B[which(is.na(data_set$Specific_Geneva56_B) & is.na(data_set$Ad_Valorem_Geneva56_B),arr.ind = TRUE)]<- # Geneva_A to Geneva_B Ad_Valorem
  data_set$Ad_Valorem_Geneva56_A[which(is.na(data_set$Specific_Geneva56_B) & is.na(data_set$Ad_Valorem_Geneva56_B),arr.ind = TRUE)]

data_set$Ad_Valorem_Geneva56_C[which(is.na(data_set$Specific_Geneva56_C) & is.na(data_set$Ad_Valorem_Geneva56_C),arr.ind = TRUE)]<- # Geneva_B to Geneva_C Ad_Valorem
  data_set$Ad_Valorem_Geneva56_B[which(is.na(data_set$Specific_Geneva56_C) & is.na(data_set$Ad_Valorem_Geneva56_C),arr.ind = TRUE)]

data_set$Ad_Valorem_Dillon_A[which(is.na(data_set$Specific_Dillon_A) & is.na(data_set$Ad_Valorem_Dillon_A),arr.ind = TRUE)]<- # Geneva_C to Dillon_A Ad_Valorem
  data_set$Ad_Valorem_Geneva56_C[which(is.na(data_set$Specific_Dillon_A) & is.na(data_set$Ad_Valorem_Dillon_A),arr.ind = TRUE)]

data_set$Ad_Valorem_Dillon_B[which(is.na(data_set$Specific_Dillon_B) & is.na(data_set$Ad_Valorem_Dillon_B),arr.ind = TRUE)]<- # Dillon_A to Dillon_B Ad_Valorem
  data_set$Ad_Valorem_Dillon_A[which(is.na(data_set$Specific_Dillon_B) & is.na(data_set$Ad_Valorem_Dillon_B),arr.ind = TRUE)]


################################### Notice that the above code cannot cover the type of tax rate that contains both specific and ad valorem, namely result becomes : 1 1 1 -> 1 NA NA
################################### Therefore two more parts have to be added for this filling process, using the guideline that "specific and unit cannot be NA and !NA simultaneously" to identify these lines.
################################### Note to start with the Ad_valorem column

data_set$Ad_Valorem_Geneva[which(!is.na(data_set$Specific_Geneva) & is.na(data_set$Units_Geneva),arr.ind = TRUE)]<- # SH to Geneva Ad_Valorem ##### Pars 2
  data_set$Ad_Valorem_SH[which(!is.na(data_set$Specific_Geneva) & is.na(data_set$Units_Geneva),arr.ind = TRUE)]

data_set$Ad_Valorem_Annecy[which(!is.na(data_set$Specific_Annecy) & is.na(data_set$Units_Annecy),arr.ind = TRUE)]<- # Geneva to Annecy Ad_Valorem ##### Pars 2
  data_set$Ad_Valorem_Geneva[which(!is.na(data_set$Specific_Annecy) & is.na(data_set$Units_Annecy),arr.ind = TRUE)]

data_set$Ad_Valorem_Torquay[which(!is.na(data_set$Specific_Torquay) & is.na(data_set$Units_Torquay),arr.ind = TRUE)]<- # Annecy to Torquay Ad_Valorem ##### Pars 2
  data_set$Ad_Valorem_Annecy[which(!is.na(data_set$Specific_Torquay) & is.na(data_set$Units_Torquay),arr.ind = TRUE)]

data_set$Ad_Valorem_Geneva56_A[which(!is.na(data_set$Specific_Geneva56_A) & is.na(data_set$Units_Geneva56_A),arr.ind = TRUE)]<- # Torquay to Geneva_A Ad_Valorem ##### Pars 2
  data_set$Ad_Valorem_Torquay[which(!is.na(data_set$Specific_Geneva56_A) & is.na(data_set$Units_Geneva56_A),arr.ind = TRUE)]

data_set$Ad_Valorem_Geneva56_B[which(!is.na(data_set$Specific_Geneva56_B) & is.na(data_set$Units_Geneva56_B),arr.ind = TRUE)]<- # Geneva_A to Geneva_B Ad_Valorem ##### Pars 2
  data_set$Ad_Valorem_Geneva56_A[which(!is.na(data_set$Specific_Geneva56_B) & is.na(data_set$Units_Geneva56_B),arr.ind = TRUE)]

data_set$Ad_Valorem_Geneva56_C[which(!is.na(data_set$Specific_Geneva56_C) & is.na(data_set$Units_Geneva56_C),arr.ind = TRUE)]<- # Geneva_B to Geneva_C Ad_Valorem ##### Pars 2
  data_set$Ad_Valorem_Geneva56_B[which(!is.na(data_set$Specific_Geneva56_C) & is.na(data_set$Units_Geneva56_C),arr.ind = TRUE)]

data_set$Ad_Valorem_Dillon_A[which(!is.na(data_set$Specific_Dillon_A) & is.na(data_set$Units_Dillon_A),arr.ind = TRUE)]<- # Geneva_C to Dillon_A Ad_Valorem ##### Pars 2
  data_set$Ad_Valorem_Geneva56_C[which(!is.na(data_set$Specific_Dillon_A) & is.na(data_set$Units_Dillon_A),arr.ind = TRUE)]

data_set$Ad_Valorem_Dillon_B[which(!is.na(data_set$Specific_Dillon_B) & is.na(data_set$Units_Dillon_B),arr.ind = TRUE)]<- # Dillon_A to Dillon_B Ad_Valorem ##### Pars 2
  data_set$Ad_Valorem_Dillon_A[which(!is.na(data_set$Specific_Dillon_B) & is.na(data_set$Units_Dillon_B),arr.ind = TRUE)]



data_set$Units_Geneva[which(!is.na(data_set$Specific_Geneva) & is.na(data_set$Units_Geneva),arr.ind = TRUE)]<- # SH to Geneva Units ##### Pars 2
  data_set$Units_SH[which(!is.na(data_set$Specific_Geneva) & is.na(data_set$Units_Geneva),arr.ind = TRUE)]

data_set$Units_Annecy[which(!is.na(data_set$Specific_Annecy) & is.na(data_set$Units_Annecy),arr.ind = TRUE)]<- # Geneva to Annecy Units ##### Pars 2
  data_set$Units_Geneva[which(!is.na(data_set$Specific_Annecy) & is.na(data_set$Units_Annecy),arr.ind = TRUE)]

data_set$Units_Torquay[which(!is.na(data_set$Specific_Torquay) & is.na(data_set$Units_Torquay),arr.ind = TRUE)]<- # Annecy to Torquay Units ##### Pars 2
  data_set$Units_Annecy[which(!is.na(data_set$Specific_Torquay) & is.na(data_set$Units_Torquay),arr.ind = TRUE)]

data_set$Units_Geneva56_A[which(!is.na(data_set$Specific_Geneva56_A) & is.na(data_set$Units_Geneva56_A),arr.ind = TRUE)]<- # Torquay to Geneva_A Units ##### Pars 2
  data_set$Units_Torquay[which(!is.na(data_set$Specific_Geneva56_A) & is.na(data_set$Units_Geneva56_A),arr.ind = TRUE)]

data_set$Units_Geneva56_B[which(!is.na(data_set$Specific_Geneva56_B) & is.na(data_set$Units_Geneva56_B),arr.ind = TRUE)]<- # Geneva_A to Geneva_B Units ##### Pars 2
  data_set$Units_Geneva56_A[which(!is.na(data_set$Specific_Geneva56_B) & is.na(data_set$Units_Geneva56_B),arr.ind = TRUE)]

data_set$Units_Geneva56_C[which(!is.na(data_set$Specific_Geneva56_C) & is.na(data_set$Units_Geneva56_C),arr.ind = TRUE)]<- # Geneva_B to Geneva_C Units ##### Pars 2
  data_set$Units_Geneva56_B[which(!is.na(data_set$Specific_Geneva56_C) & is.na(data_set$Units_Geneva56_C),arr.ind = TRUE)]

data_set$Units_Dillon_A[which(!is.na(data_set$Specific_Dillon_A) & is.na(data_set$Units_Dillon_A),arr.ind = TRUE)]<- # Geneva_C to Dillon_A Units ##### Pars 2
  data_set$Units_Geneva56_C[which(!is.na(data_set$Specific_Dillon_A) & is.na(data_set$Units_Dillon_A),arr.ind = TRUE)]

data_set$Units_Dillon_B[which(!is.na(data_set$Specific_Dillon_B) & is.na(data_set$Units_Dillon_B),arr.ind = TRUE)]<- # Dillon_A to Dillon_B Units ##### Pars 2
  data_set$Units_Dillon_A[which(!is.na(data_set$Specific_Dillon_B) & is.na(data_set$Units_Dillon_B),arr.ind = TRUE)]






##############################################################################################################################################################
### Change the units
##############################################################################################################################################################

################################################################################ Step 1, replace the units without change of the values.


data_set$Units_SH[data_set$Units_SH==11]<-6 #################################### 11 to 6
data_set$Units_Geneva[data_set$Units_Geneva==11]<-6
data_set$Units_Annecy[data_set$Units_Annecy==11]<-6
data_set$Units_Torquay[data_set$Units_Torquay==11]<-6
data_set$Units_Geneva56_A[data_set$Units_Geneva56_A==11]<-6
data_set$Units_Geneva56_B[data_set$Units_Geneva56_B==11]<-6
data_set$Units_Geneva56_C[data_set$Units_Geneva56_C==11]<-6
data_set$Units_Dillon_A[data_set$Units_Dillon_A==11]<-6
data_set$Units_Dillon_B[data_set$Units_Dillon_B==11]<-6


data_set$Units_SH[data_set$Units_SH==12]<-19 #################################### 12 to 19
data_set$Units_Geneva[data_set$Units_Geneva==12]<-19
data_set$Units_Annecy[data_set$Units_Annecy==12]<-19
data_set$Units_Torquay[data_set$Units_Torquay==12]<-19
data_set$Units_Geneva56_A[data_set$Units_Geneva56_A==12]<-19
data_set$Units_Geneva56_B[data_set$Units_Geneva56_B==12]<-19
data_set$Units_Geneva56_C[data_set$Units_Geneva56_C==12]<-19
data_set$Units_Dillon_A[data_set$Units_Dillon_A==12]<-19
data_set$Units_Dillon_B[data_set$Units_Dillon_B==12]<-19


data_set$Units_SH[data_set$Units_SH==13]<-9 #################################### 13 to 9
data_set$Units_Geneva[data_set$Units_Geneva==13]<-9
data_set$Units_Annecy[data_set$Units_Annecy==13]<-9
data_set$Units_Torquay[data_set$Units_Torquay==13]<-9
data_set$Units_Geneva56_A[data_set$Units_Geneva56_A==13]<-9
data_set$Units_Geneva56_B[data_set$Units_Geneva56_B==13]<-9
data_set$Units_Geneva56_C[data_set$Units_Geneva56_C==13]<-9
data_set$Units_Dillon_A[data_set$Units_Dillon_A==13]<-9
data_set$Units_Dillon_B[data_set$Units_Dillon_B==13]<-9

data_set$Units_SH[data_set$Units_SH==16]<-20 #################################### 16 to 20
data_set$Units_Geneva[data_set$Units_Geneva==16]<-20
data_set$Units_Annecy[data_set$Units_Annecy==16]<-20
data_set$Units_Torquay[data_set$Units_Torquay==16]<-20
data_set$Units_Geneva56_A[data_set$Units_Geneva56_A==16]<-20
data_set$Units_Geneva56_B[data_set$Units_Geneva56_B==16]<-20
data_set$Units_Geneva56_C[data_set$Units_Geneva56_C==16]<-20
data_set$Units_Dillon_A[data_set$Units_Dillon_A==16]<-20
data_set$Units_Dillon_B[data_set$Units_Dillon_B==16]<-20


data_set$Units_SH[data_set$Units_SH==17]<-20 #################################### 17 to 20
data_set$Units_Geneva[data_set$Units_Geneva==17]<-20
data_set$Units_Annecy[data_set$Units_Annecy==17]<-20
data_set$Units_Torquay[data_set$Units_Torquay==17]<-20
data_set$Units_Geneva56_A[data_set$Units_Geneva56_A==17]<-20
data_set$Units_Geneva56_B[data_set$Units_Geneva56_B==17]<-20
data_set$Units_Geneva56_C[data_set$Units_Geneva56_C==17]<-20
data_set$Units_Dillon_A[data_set$Units_Dillon_A==17]<-20
data_set$Units_Dillon_B[data_set$Units_Dillon_B==17]<-20


data_set$Units_SH[data_set$Units_SH==21]<-20 #################################### 21 to 20
data_set$Units_Geneva[data_set$Units_Geneva==21]<-20
data_set$Units_Annecy[data_set$Units_Annecy==21]<-20
data_set$Units_Torquay[data_set$Units_Torquay==21]<-20
data_set$Units_Geneva56_A[data_set$Units_Geneva56_A==21]<-20
data_set$Units_Geneva56_B[data_set$Units_Geneva56_B==21]<-20
data_set$Units_Geneva56_C[data_set$Units_Geneva56_C==21]<-20
data_set$Units_Dillon_A[data_set$Units_Dillon_A==21]<-20
data_set$Units_Dillon_B[data_set$Units_Dillon_B==21]<-20

data_set$Units_SH[data_set$Units_SH==26]<-19 #################################### 26 to 19
data_set$Units_Geneva[data_set$Units_Geneva==26]<-19
data_set$Units_Annecy[data_set$Units_Annecy==26]<-19
data_set$Units_Torquay[data_set$Units_Torquay==26]<-19
data_set$Units_Geneva56_A[data_set$Units_Geneva56_A==26]<-19
data_set$Units_Geneva56_B[data_set$Units_Geneva56_B==26]<-19
data_set$Units_Geneva56_C[data_set$Units_Geneva56_C==26]<-19
data_set$Units_Dillon_A[data_set$Units_Dillon_A==26]<-19
data_set$Units_Dillon_B[data_set$Units_Dillon_B==26]<-19


data_set$Units_SH[data_set$Units_SH==31]<-19 #################################### 31 to 19
data_set$Units_Geneva[data_set$Units_Geneva==31]<-19
data_set$Units_Annecy[data_set$Units_Annecy==31]<-19
data_set$Units_Torquay[data_set$Units_Torquay==31]<-19
data_set$Units_Geneva56_A[data_set$Units_Geneva56_A==31]<-19
data_set$Units_Geneva56_B[data_set$Units_Geneva56_B==31]<-19
data_set$Units_Geneva56_C[data_set$Units_Geneva56_C==31]<-19
data_set$Units_Dillon_A[data_set$Units_Dillon_A==31]<-19
data_set$Units_Dillon_B[data_set$Units_Dillon_B==31]<-19


data_set$Units_SH[data_set$Units_SH==32]<-25 #################################### 32 to 25
data_set$Units_Geneva[data_set$Units_Geneva==32]<-25
data_set$Units_Annecy[data_set$Units_Annecy==32]<-25
data_set$Units_Torquay[data_set$Units_Torquay==32]<-25
data_set$Units_Geneva56_A[data_set$Units_Geneva56_A==32]<-25
data_set$Units_Geneva56_B[data_set$Units_Geneva56_B==32]<-25
data_set$Units_Geneva56_C[data_set$Units_Geneva56_C==32]<-25
data_set$Units_Dillon_A[data_set$Units_Dillon_A==32]<-25
data_set$Units_Dillon_B[data_set$Units_Dillon_B==32]<-25


data_set$Units_SH[data_set$Units_SH==38]<-2 #################################### 38 to 2
data_set$Units_Geneva[data_set$Units_Geneva==38]<-2
data_set$Units_Annecy[data_set$Units_Annecy==38]<-2
data_set$Units_Torquay[data_set$Units_Torquay==38]<-2
data_set$Units_Geneva56_A[data_set$Units_Geneva56_A==38]<-2
data_set$Units_Geneva56_B[data_set$Units_Geneva56_B==38]<-2
data_set$Units_Geneva56_C[data_set$Units_Geneva56_C==38]<-2
data_set$Units_Dillon_A[data_set$Units_Dillon_A==38]<-2
data_set$Units_Dillon_B[data_set$Units_Dillon_B==38]<-2


data_set$Units_SH[data_set$Units_SH==43]<-1 #################################### 43 to 1
data_set$Units_Geneva[data_set$Units_Geneva==43]<-1
data_set$Units_Annecy[data_set$Units_Annecy==43]<-1
data_set$Units_Torquay[data_set$Units_Torquay==43]<-1
data_set$Units_Geneva56_A[data_set$Units_Geneva56_A==43]<-1
data_set$Units_Geneva56_B[data_set$Units_Geneva56_B==43]<-1
data_set$Units_Geneva56_C[data_set$Units_Geneva56_C==43]<-1
data_set$Units_Dillon_A[data_set$Units_Dillon_A==43]<-1
data_set$Units_Dillon_B[data_set$Units_Dillon_B==43]<-1


data_set$Units_SH[data_set$Units_SH==45]<-48 #################################### 45 to 48
data_set$Units_Geneva[data_set$Units_Geneva==45]<-48
data_set$Units_Annecy[data_set$Units_Annecy==45]<-48
data_set$Units_Torquay[data_set$Units_Torquay==45]<-48
data_set$Units_Geneva56_A[data_set$Units_Geneva56_A==45]<-48
data_set$Units_Geneva56_B[data_set$Units_Geneva56_B==45]<-48
data_set$Units_Geneva56_C[data_set$Units_Geneva56_C==45]<-48
data_set$Units_Dillon_A[data_set$Units_Dillon_A==45]<-48
data_set$Units_Dillon_B[data_set$Units_Dillon_B==45]<-48


data_set$Units_SH[data_set$Units_SH==47]<-3 #################################### 47 to 3
data_set$Units_Geneva[data_set$Units_Geneva==47]<-3
data_set$Units_Annecy[data_set$Units_Annecy==47]<-3
data_set$Units_Torquay[data_set$Units_Torquay==47]<-3
data_set$Units_Geneva56_A[data_set$Units_Geneva56_A==47]<-3
data_set$Units_Geneva56_B[data_set$Units_Geneva56_B==47]<-3
data_set$Units_Geneva56_C[data_set$Units_Geneva56_C==47]<-3
data_set$Units_Dillon_A[data_set$Units_Dillon_A==47]<-3
data_set$Units_Dillon_B[data_set$Units_Dillon_B==47]<-3


data_set$Units_SH[data_set$Units_SH==51]<-19 #################################### 51 to 19
data_set$Units_Geneva[data_set$Units_Geneva==51]<-19
data_set$Units_Annecy[data_set$Units_Annecy==51]<-19
data_set$Units_Torquay[data_set$Units_Torquay==51]<-19
data_set$Units_Geneva56_A[data_set$Units_Geneva56_A==51]<-19
data_set$Units_Geneva56_B[data_set$Units_Geneva56_B==51]<-19
data_set$Units_Geneva56_C[data_set$Units_Geneva56_C==51]<-19
data_set$Units_Dillon_A[data_set$Units_Dillon_A==51]<-19
data_set$Units_Dillon_B[data_set$Units_Dillon_B==51]<-19

################################################################################ Step 2, replace the units that also involve changes in value 

#f_replace<-function(m,n,p){
#  arr1<-which(data_set$Units_SH==m,arr.ind=TRUE)
#  data_set$Specific_SH[arr1]<-data_set$Specific_SH[arr1]*p
#  data_set$Units_SH[arr1]<-n
#}

################################################################################################################ 14 to 1 divided by 1000
arr<-which(data_set$Units_SH==14,arr.ind = TRUE)
data_set$Specific_SH[arr]<-data_set$Specific_SH[arr]/100
data_set$Units_SH[arr]<-1

arr<-which(data_set$Units_Geneva==14,arr.ind = TRUE)
data_set$Specific_Geneva[arr]<-data_set$Specific_Geneva[arr]/100
data_set$Units_Geneva[arr]<-1

arr<-which(data_set$Units_Annecy==14,arr.ind = TRUE)
data_set$Specific_Annecy[arr]<-data_set$Specific_Annecy[arr]/100
data_set$Units_Annecy[arr]<-1

arr<-which(data_set$Units_Torquay==14,arr.ind = TRUE)
data_set$Specific_Torquay[arr]<-data_set$Specific_Torquay[arr]/100
data_set$Units_Torquay[arr]<-1

arr<-which(data_set$Units_Geneva56_A==14,arr.ind = TRUE)
data_set$Specific_Geneva56_A[arr]<-data_set$Specific_Geneva56_A[arr]/100
data_set$Units_Geneva56_A[arr]<-1

arr<-which(data_set$Units_Geneva56_B==14,arr.ind = TRUE)
data_set$Specific_Geneva56_B[arr]<-data_set$Specific_Geneva56_B[arr]/100
data_set$Units_Geneva56_B[arr]<-1

arr<-which(data_set$Units_Geneva56_C==14,arr.ind = TRUE)
data_set$Specific_Geneva56_C[arr]<-data_set$Specific_Geneva56_C[arr]/100
data_set$Units_Geneva56_C[arr]<-1

arr<-which(data_set$Units_Dillon_A==14,arr.ind = TRUE)
data_set$Specific_Dillon_A[arr]<-data_set$Specific_Dillon_A[arr]/100
data_set$Units_Dillon_A[arr]<-1

arr<-which(data_set$Units_Dillon_B==14,arr.ind = TRUE)
data_set$Specific_Dillon_B[arr]<-data_set$Specific_Dillon_B[arr]/100
data_set$Units_Dillon_B[arr]<-1


################################################################################################################ 15 to 1 divided by 1000
arr<-which(data_set$Units_SH==15,arr.ind = TRUE)
data_set$Specific_SH[arr]<-data_set$Specific_SH[arr]/1000
data_set$Units_SH[arr]<-1

arr<-which(data_set$Units_Geneva==15,arr.ind = TRUE)
data_set$Specific_Geneva[arr]<-data_set$Specific_Geneva[arr]/1000
data_set$Units_Geneva[arr]<-1

arr<-which(data_set$Units_Annecy==15,arr.ind = TRUE)
data_set$Specific_Annecy[arr]<-data_set$Specific_Annecy[arr]/1000
data_set$Units_Annecy[arr]<-1

arr<-which(data_set$Units_Torquay==15,arr.ind = TRUE)
data_set$Specific_Torquay[arr]<-data_set$Specific_Torquay[arr]/1000
data_set$Units_Torquay[arr]<-1

arr<-which(data_set$Units_Geneva56_A==15,arr.ind = TRUE)
data_set$Specific_Geneva56_A[arr]<-data_set$Specific_Geneva56_A[arr]/1000
data_set$Units_Geneva56_A[arr]<-1

arr<-which(data_set$Units_Geneva56_B==15,arr.ind = TRUE)
data_set$Specific_Geneva56_B[arr]<-data_set$Specific_Geneva56_B[arr]/1000
data_set$Units_Geneva56_B[arr]<-1

arr<-which(data_set$Units_Geneva56_C==15,arr.ind = TRUE)
data_set$Specific_Geneva56_C[arr]<-data_set$Specific_Geneva56_C[arr]/1000
data_set$Units_Geneva56_C[arr]<-1

arr<-which(data_set$Units_Dillon_A==15,arr.ind = TRUE)
data_set$Specific_Dillon_A[arr]<-data_set$Specific_Dillon_A[arr]/1000
data_set$Units_Dillon_A[arr]<-1

arr<-which(data_set$Units_Dillon_B==15,arr.ind = TRUE)
data_set$Specific_Dillon_B[arr]<-data_set$Specific_Dillon_B[arr]/1000
data_set$Units_Dillon_B[arr]<-1


################################################################################################################ 22 to 25 divided by 1000
arr<-which(data_set$Units_SH==22,arr.ind = TRUE)
data_set$Specific_SH[arr]<-data_set$Specific_SH[arr]/1000
data_set$Units_SH[arr]<-25

arr<-which(data_set$Units_Geneva==22,arr.ind = TRUE)
data_set$Specific_Geneva[arr]<-data_set$Specific_Geneva[arr]/1000
data_set$Units_Geneva[arr]<-25

arr<-which(data_set$Units_Annecy==22,arr.ind = TRUE)
data_set$Specific_Annecy[arr]<-data_set$Specific_Annecy[arr]/1000
data_set$Units_Annecy[arr]<-25

arr<-which(data_set$Units_Torquay==22,arr.ind = TRUE)
data_set$Specific_Torquay[arr]<-data_set$Specific_Torquay[arr]/1000
data_set$Units_Torquay[arr]<-25

arr<-which(data_set$Units_Geneva56_A==22,arr.ind = TRUE)
data_set$Specific_Geneva56_A[arr]<-data_set$Specific_Geneva56_A[arr]/1000
data_set$Units_Geneva56_A[arr]<-25

arr<-which(data_set$Units_Geneva56_B==22,arr.ind = TRUE)
data_set$Specific_Geneva56_B[arr]<-data_set$Specific_Geneva56_B[arr]/1000
data_set$Units_Geneva56_B[arr]<-25

arr<-which(data_set$Units_Geneva56_C==22,arr.ind = TRUE)
data_set$Specific_Geneva56_C[arr]<-data_set$Specific_Geneva56_C[arr]/1000
data_set$Units_Geneva56_C[arr]<-25

arr<-which(data_set$Units_Dillon_A==22,arr.ind = TRUE)
data_set$Specific_Dillon_A[arr]<-data_set$Specific_Dillon_A[arr]/1000
data_set$Units_Dillon_A[arr]<-25

arr<-which(data_set$Units_Dillon_B==22,arr.ind = TRUE)
data_set$Specific_Dillon_B[arr]<-data_set$Specific_Dillon_B[arr]/1000
data_set$Units_Dillon_B[arr]<-25

################################################################################################################ 23 to 19 divided by 100
arr<-which(data_set$Units_SH==23,arr.ind = TRUE)
data_set$Specific_SH[arr]<-data_set$Specific_SH[arr]/100
data_set$Units_SH[arr]<-19

arr<-which(data_set$Units_Geneva==23,arr.ind = TRUE)
data_set$Specific_Geneva[arr]<-data_set$Specific_Geneva[arr]/100
data_set$Units_Geneva[arr]<-19

arr<-which(data_set$Units_Annecy==23,arr.ind = TRUE)
data_set$Specific_Annecy[arr]<-data_set$Specific_Annecy[arr]/100
data_set$Units_Annecy[arr]<-19

arr<-which(data_set$Units_Torquay==23,arr.ind = TRUE)
data_set$Specific_Torquay[arr]<-data_set$Specific_Torquay[arr]/100
data_set$Units_Torquay[arr]<-19

arr<-which(data_set$Units_Geneva56_A==23,arr.ind = TRUE)
data_set$Specific_Geneva56_A[arr]<-data_set$Specific_Geneva56_A[arr]/100
data_set$Units_Geneva56_A[arr]<-19

arr<-which(data_set$Units_Geneva56_B==23,arr.ind = TRUE)
data_set$Specific_Geneva56_B[arr]<-data_set$Specific_Geneva56_B[arr]/100
data_set$Units_Geneva56_B[arr]<-19

arr<-which(data_set$Units_Geneva56_C==23,arr.ind = TRUE)
data_set$Specific_Geneva56_C[arr]<-data_set$Specific_Geneva56_C[arr]/100
data_set$Units_Geneva56_C[arr]<-19

arr<-which(data_set$Units_Dillon_A==23,arr.ind = TRUE)
data_set$Specific_Dillon_A[arr]<-data_set$Specific_Dillon_A[arr]/100
data_set$Units_Dillon_A[arr]<-19

arr<-which(data_set$Units_Dillon_B==23,arr.ind = TRUE)
data_set$Specific_Dillon_B[arr]<-data_set$Specific_Dillon_B[arr]/100
data_set$Units_Dillon_B[arr]<-19


################################################################################################################ 27 to 19 divided by 100
arr<-which(data_set$Units_SH==27,arr.ind = TRUE)
data_set$Specific_SH[arr]<-data_set$Specific_SH[arr]/100
data_set$Units_SH[arr]<-19

arr<-which(data_set$Units_Geneva==27,arr.ind = TRUE)
data_set$Specific_Geneva[arr]<-data_set$Specific_Geneva[arr]/100
data_set$Units_Geneva[arr]<-19

arr<-which(data_set$Units_Annecy==27,arr.ind = TRUE)
data_set$Specific_Annecy[arr]<-data_set$Specific_Annecy[arr]/100
data_set$Units_Annecy[arr]<-19

arr<-which(data_set$Units_Torquay==27,arr.ind = TRUE)
data_set$Specific_Torquay[arr]<-data_set$Specific_Torquay[arr]/100
data_set$Units_Torquay[arr]<-19

arr<-which(data_set$Units_Geneva56_A==27,arr.ind = TRUE)
data_set$Specific_Geneva56_A[arr]<-data_set$Specific_Geneva56_A[arr]/100
data_set$Units_Geneva56_A[arr]<-19

arr<-which(data_set$Units_Geneva56_B==27,arr.ind = TRUE)
data_set$Specific_Geneva56_B[arr]<-data_set$Specific_Geneva56_B[arr]/100
data_set$Units_Geneva56_B[arr]<-19

arr<-which(data_set$Units_Geneva56_C==27,arr.ind = TRUE)
data_set$Specific_Geneva56_C[arr]<-data_set$Specific_Geneva56_C[arr]/100
data_set$Units_Geneva56_C[arr]<-19

arr<-which(data_set$Units_Dillon_A==27,arr.ind = TRUE)
data_set$Specific_Dillon_A[arr]<-data_set$Specific_Dillon_A[arr]/100
data_set$Units_Dillon_A[arr]<-19

arr<-which(data_set$Units_Dillon_B==27,arr.ind = TRUE)
data_set$Specific_Dillon_B[arr]<-data_set$Specific_Dillon_B[arr]/100
data_set$Units_Dillon_B[arr]<-19

################################################################################################################ 39 to 25 divided by 1000
arr<-which(data_set$Units_SH==39,arr.ind = TRUE)
data_set$Specific_SH[arr]<-data_set$Specific_SH[arr]/1000
data_set$Units_SH[arr]<-25

arr<-which(data_set$Units_Geneva==39,arr.ind = TRUE)
data_set$Specific_Geneva[arr]<-data_set$Specific_Geneva[arr]/1000
data_set$Units_Geneva[arr]<-25

arr<-which(data_set$Units_Annecy==39,arr.ind = TRUE)
data_set$Specific_Annecy[arr]<-data_set$Specific_Annecy[arr]/1000
data_set$Units_Annecy[arr]<-25

arr<-which(data_set$Units_Torquay==39,arr.ind = TRUE)
data_set$Specific_Torquay[arr]<-data_set$Specific_Torquay[arr]/1000
data_set$Units_Torquay[arr]<-25

arr<-which(data_set$Units_Geneva56_A==39,arr.ind = TRUE)
data_set$Specific_Geneva56_A[arr]<-data_set$Specific_Geneva56_A[arr]/1000
data_set$Units_Geneva56_A[arr]<-25

arr<-which(data_set$Units_Geneva56_B==39,arr.ind = TRUE)
data_set$Specific_Geneva56_B[arr]<-data_set$Specific_Geneva56_B[arr]/1000
data_set$Units_Geneva56_B[arr]<-25

arr<-which(data_set$Units_Geneva56_C==39,arr.ind = TRUE)
data_set$Specific_Geneva56_C[arr]<-data_set$Specific_Geneva56_C[arr]/1000
data_set$Units_Geneva56_C[arr]<-25

arr<-which(data_set$Units_Dillon_A==39,arr.ind = TRUE)
data_set$Specific_Dillon_A[arr]<-data_set$Specific_Dillon_A[arr]/1000
data_set$Units_Dillon_A[arr]<-25

arr<-which(data_set$Units_Dillon_B==39,arr.ind = TRUE)
data_set$Specific_Dillon_B[arr]<-data_set$Specific_Dillon_B[arr]/1000
data_set$Units_Dillon_B[arr]<-25


################################################################################################################ 40 to 3 divided by 1000
arr<-which(data_set$Units_SH==40,arr.ind = TRUE)
data_set$Specific_SH[arr]<-data_set$Specific_SH[arr]/2000
data_set$Units_SH[arr]<-3

arr<-which(data_set$Units_Geneva==40,arr.ind = TRUE)
data_set$Specific_Geneva[arr]<-data_set$Specific_Geneva[arr]/2000
data_set$Units_Geneva[arr]<-3

arr<-which(data_set$Units_Annecy==40,arr.ind = TRUE)
data_set$Specific_Annecy[arr]<-data_set$Specific_Annecy[arr]/2000
data_set$Units_Annecy[arr]<-3

arr<-which(data_set$Units_Torquay==40,arr.ind = TRUE)
data_set$Specific_Torquay[arr]<-data_set$Specific_Torquay[arr]/2000
data_set$Units_Torquay[arr]<-3

arr<-which(data_set$Units_Geneva56_A==40,arr.ind = TRUE)
data_set$Specific_Geneva56_A[arr]<-data_set$Specific_Geneva56_A[arr]/2000
data_set$Units_Geneva56_A[arr]<-3

arr<-which(data_set$Units_Geneva56_B==40,arr.ind = TRUE)
data_set$Specific_Geneva56_B[arr]<-data_set$Specific_Geneva56_B[arr]/2000
data_set$Units_Geneva56_B[arr]<-3

arr<-which(data_set$Units_Geneva56_C==40,arr.ind = TRUE)
data_set$Specific_Geneva56_C[arr]<-data_set$Specific_Geneva56_C[arr]/2000
data_set$Units_Geneva56_C[arr]<-3

arr<-which(data_set$Units_Dillon_A==40,arr.ind = TRUE)
data_set$Specific_Dillon_A[arr]<-data_set$Specific_Dillon_A[arr]/2000
data_set$Units_Dillon_A[arr]<-3

arr<-which(data_set$Units_Dillon_B==40,arr.ind = TRUE)
data_set$Specific_Dillon_B[arr]<-data_set$Specific_Dillon_B[arr]/2000
data_set$Units_Dillon_B[arr]<-3


################################################################################################################ 50 to 19 divided by 1000
arr<-which(data_set$Units_SH==50,arr.ind = TRUE)
data_set$Specific_SH[arr]<-data_set$Specific_SH[arr]/1000
data_set$Units_SH[arr]<-19

arr<-which(data_set$Units_Geneva==50,arr.ind = TRUE)
data_set$Specific_Geneva[arr]<-data_set$Specific_Geneva[arr]/1000
data_set$Units_Geneva[arr]<-19

arr<-which(data_set$Units_Annecy==50,arr.ind = TRUE)
data_set$Specific_Annecy[arr]<-data_set$Specific_Annecy[arr]/1000
data_set$Units_Annecy[arr]<-19

arr<-which(data_set$Units_Torquay==50,arr.ind = TRUE)
data_set$Specific_Torquay[arr]<-data_set$Specific_Torquay[arr]/1000
data_set$Units_Torquay[arr]<-19

arr<-which(data_set$Units_Geneva56_A==50,arr.ind = TRUE)
data_set$Specific_Geneva56_A[arr]<-data_set$Specific_Geneva56_A[arr]/1000
data_set$Units_Geneva56_A[arr]<-19

arr<-which(data_set$Units_Geneva56_B==50,arr.ind = TRUE)
data_set$Specific_Geneva56_B[arr]<-data_set$Specific_Geneva56_B[arr]/1000
data_set$Units_Geneva56_B[arr]<-19

arr<-which(data_set$Units_Geneva56_C==50,arr.ind = TRUE)
data_set$Specific_Geneva56_C[arr]<-data_set$Specific_Geneva56_C[arr]/1000
data_set$Units_Geneva56_C[arr]<-19

arr<-which(data_set$Units_Dillon_A==50,arr.ind = TRUE)
data_set$Specific_Dillon_A[arr]<-data_set$Specific_Dillon_A[arr]/1000
data_set$Units_Dillon_A[arr]<-19

arr<-which(data_set$Units_Dillon_B==50,arr.ind = TRUE)
data_set$Specific_Dillon_B[arr]<-data_set$Specific_Dillon_B[arr]/1000
data_set$Units_Dillon_B[arr]<-19


################################################################################################################ 56 to 54 divided by 100
arr<-which(data_set$Units_SH==56,arr.ind = TRUE)
data_set$Specific_SH[arr]<-data_set$Specific_SH[arr]/100
data_set$Units_SH[arr]<-54

arr<-which(data_set$Units_Geneva==56,arr.ind = TRUE)
data_set$Specific_Geneva[arr]<-data_set$Specific_Geneva[arr]/100
data_set$Units_Geneva[arr]<-54

arr<-which(data_set$Units_Annecy==56,arr.ind = TRUE)
data_set$Specific_Annecy[arr]<-data_set$Specific_Annecy[arr]/100
data_set$Units_Annecy[arr]<-54

arr<-which(data_set$Units_Torquay==56,arr.ind = TRUE)
data_set$Specific_Torquay[arr]<-data_set$Specific_Torquay[arr]/100
data_set$Units_Torquay[arr]<-54

arr<-which(data_set$Units_Geneva56_A==56,arr.ind = TRUE)
data_set$Specific_Geneva56_A[arr]<-data_set$Specific_Geneva56_A[arr]/100
data_set$Units_Geneva56_A[arr]<-54

arr<-which(data_set$Units_Geneva56_B==56,arr.ind = TRUE)
data_set$Specific_Geneva56_B[arr]<-data_set$Specific_Geneva56_B[arr]/100
data_set$Units_Geneva56_B[arr]<-54

arr<-which(data_set$Units_Geneva56_C==56,arr.ind = TRUE)
data_set$Specific_Geneva56_C[arr]<-data_set$Specific_Geneva56_C[arr]/100
data_set$Units_Geneva56_C[arr]<-54

arr<-which(data_set$Units_Dillon_A==56,arr.ind = TRUE)
data_set$Specific_Dillon_A[arr]<-data_set$Specific_Dillon_A[arr]/100
data_set$Units_Dillon_A[arr]<-54

arr<-which(data_set$Units_Dillon_B==56,arr.ind = TRUE)
data_set$Specific_Dillon_B[arr]<-data_set$Specific_Dillon_B[arr]/100
data_set$Units_Dillon_B[arr]<-54

################################################################################ Step 3, replace the dollar with cents 

################################################################################################################ 3 to 1
arr<-which(data_set$Units_SH==3,arr.ind = TRUE)
data_set$Specific_SH[arr]<-data_set$Specific_SH[arr]*100
data_set$Units_SH[arr]<-1

arr<-which(data_set$Units_Geneva==3,arr.ind = TRUE)
data_set$Specific_Geneva[arr]<-data_set$Specific_Geneva[arr]*100
data_set$Units_Geneva[arr]<-1

arr<-which(data_set$Units_Annecy==3,arr.ind = TRUE)
data_set$Specific_Annecy[arr]<-data_set$Specific_Annecy[arr]*100
data_set$Units_Annecy[arr]<-1

arr<-which(data_set$Units_Torquay==3,arr.ind = TRUE)
data_set$Specific_Torquay[arr]<-data_set$Specific_Torquay[arr]*100
data_set$Units_Torquay[arr]<-1

arr<-which(data_set$Units_Geneva56_A==3,arr.ind = TRUE)
data_set$Specific_Geneva56_A[arr]<-data_set$Specific_Geneva56_A[arr]*100
data_set$Units_Geneva56_A[arr]<-1

arr<-which(data_set$Units_Geneva56_B==3,arr.ind = TRUE)
data_set$Specific_Geneva56_B[arr]<-data_set$Specific_Geneva56_B[arr]*100
data_set$Units_Geneva56_B[arr]<-1

arr<-which(data_set$Units_Geneva56_C==3,arr.ind = TRUE)
data_set$Specific_Geneva56_C[arr]<-data_set$Specific_Geneva56_C[arr]*100
data_set$Units_Geneva56_C[arr]<-1

arr<-which(data_set$Units_Dillon_A==3,arr.ind = TRUE)
data_set$Specific_Dillon_A[arr]<-data_set$Specific_Dillon_A[arr]*100
data_set$Units_Dillon_A[arr]<-1

arr<-which(data_set$Units_Dillon_B==3,arr.ind = TRUE)
data_set$Specific_Dillon_B[arr]<-data_set$Specific_Dillon_B[arr]*100
data_set$Units_Dillon_B[arr]<-1


################################################################################################################ 8 to 7
arr<-which(data_set$Units_SH==8,arr.ind = TRUE)
data_set$Specific_SH[arr]<-data_set$Specific_SH[arr]*100
data_set$Units_SH[arr]<-7

arr<-which(data_set$Units_Geneva==8,arr.ind = TRUE)
data_set$Specific_Geneva[arr]<-data_set$Specific_Geneva[arr]*100
data_set$Units_Geneva[arr]<-7

arr<-which(data_set$Units_Annecy==8,arr.ind = TRUE)
data_set$Specific_Annecy[arr]<-data_set$Specific_Annecy[arr]*100
data_set$Units_Annecy[arr]<-7

arr<-which(data_set$Units_Torquay==8,arr.ind = TRUE)
data_set$Specific_Torquay[arr]<-data_set$Specific_Torquay[arr]*100
data_set$Units_Torquay[arr]<-7

arr<-which(data_set$Units_Geneva56_A==8,arr.ind = TRUE)
data_set$Specific_Geneva56_A[arr]<-data_set$Specific_Geneva56_A[arr]*100
data_set$Units_Geneva56_A[arr]<-7

arr<-which(data_set$Units_Geneva56_B==8,arr.ind = TRUE)
data_set$Specific_Geneva56_B[arr]<-data_set$Specific_Geneva56_B[arr]*100
data_set$Units_Geneva56_B[arr]<-7

arr<-which(data_set$Units_Geneva56_C==8,arr.ind = TRUE)
data_set$Specific_Geneva56_C[arr]<-data_set$Specific_Geneva56_C[arr]*100
data_set$Units_Geneva56_C[arr]<-7

arr<-which(data_set$Units_Dillon_A==8,arr.ind = TRUE)
data_set$Specific_Dillon_A[arr]<-data_set$Specific_Dillon_A[arr]*100
data_set$Units_Dillon_A[arr]<-7

arr<-which(data_set$Units_Dillon_B==8,arr.ind = TRUE)
data_set$Specific_Dillon_B[arr]<-data_set$Specific_Dillon_B[arr]*100
data_set$Units_Dillon_B[arr]<-7


################################################################################################################ 9 to 2
arr<-which(data_set$Units_SH==9,arr.ind = TRUE)
data_set$Specific_SH[arr]<-data_set$Specific_SH[arr]*100
data_set$Units_SH[arr]<-2

arr<-which(data_set$Units_Geneva==9,arr.ind = TRUE)
data_set$Specific_Geneva[arr]<-data_set$Specific_Geneva[arr]*100
data_set$Units_Geneva[arr]<-2

arr<-which(data_set$Units_Annecy==9,arr.ind = TRUE)
data_set$Specific_Annecy[arr]<-data_set$Specific_Annecy[arr]*100
data_set$Units_Annecy[arr]<-2

arr<-which(data_set$Units_Torquay==9,arr.ind = TRUE)
data_set$Specific_Torquay[arr]<-data_set$Specific_Torquay[arr]*100
data_set$Units_Torquay[arr]<-2

arr<-which(data_set$Units_Geneva56_A==9,arr.ind = TRUE)
data_set$Specific_Geneva56_A[arr]<-data_set$Specific_Geneva56_A[arr]*100
data_set$Units_Geneva56_A[arr]<-2

arr<-which(data_set$Units_Geneva56_B==9,arr.ind = TRUE)
data_set$Specific_Geneva56_B[arr]<-data_set$Specific_Geneva56_B[arr]*100
data_set$Units_Geneva56_B[arr]<-2

arr<-which(data_set$Units_Geneva56_C==9,arr.ind = TRUE)
data_set$Specific_Geneva56_C[arr]<-data_set$Specific_Geneva56_C[arr]*100
data_set$Units_Geneva56_C[arr]<-2

arr<-which(data_set$Units_Dillon_A==9,arr.ind = TRUE)
data_set$Specific_Dillon_A[arr]<-data_set$Specific_Dillon_A[arr]*100
data_set$Units_Dillon_A[arr]<-2

arr<-which(data_set$Units_Dillon_B==9,arr.ind = TRUE)
data_set$Specific_Dillon_B[arr]<-data_set$Specific_Dillon_B[arr]*100
data_set$Units_Dillon_B[arr]<-2


################################################################################################################ 25 to 19
arr<-which(data_set$Units_SH==25,arr.ind = TRUE)
data_set$Specific_SH[arr]<-data_set$Specific_SH[arr]*100
data_set$Units_SH[arr]<-19

arr<-which(data_set$Units_Geneva==25,arr.ind = TRUE)
data_set$Specific_Geneva[arr]<-data_set$Specific_Geneva[arr]*100
data_set$Units_Geneva[arr]<-19

arr<-which(data_set$Units_Annecy==25,arr.ind = TRUE)
data_set$Specific_Annecy[arr]<-data_set$Specific_Annecy[arr]*100
data_set$Units_Annecy[arr]<-19

arr<-which(data_set$Units_Torquay==25,arr.ind = TRUE)
data_set$Specific_Torquay[arr]<-data_set$Specific_Torquay[arr]*100
data_set$Units_Torquay[arr]<-19

arr<-which(data_set$Units_Geneva56_A==25,arr.ind = TRUE)
data_set$Specific_Geneva56_A[arr]<-data_set$Specific_Geneva56_A[arr]*100
data_set$Units_Geneva56_A[arr]<-19

arr<-which(data_set$Units_Geneva56_B==25,arr.ind = TRUE)
data_set$Specific_Geneva56_B[arr]<-data_set$Specific_Geneva56_B[arr]*100
data_set$Units_Geneva56_B[arr]<-19

arr<-which(data_set$Units_Geneva56_C==25,arr.ind = TRUE)
data_set$Specific_Geneva56_C[arr]<-data_set$Specific_Geneva56_C[arr]*100
data_set$Units_Geneva56_C[arr]<-19

arr<-which(data_set$Units_Dillon_A==25,arr.ind = TRUE)
data_set$Specific_Dillon_A[arr]<-data_set$Specific_Dillon_A[arr]*100
data_set$Units_Dillon_A[arr]<-19

arr<-which(data_set$Units_Dillon_B==25,arr.ind = TRUE)
data_set$Specific_Dillon_B[arr]<-data_set$Specific_Dillon_B[arr]*100
data_set$Units_Dillon_B[arr]<-19


################################################################################################################ 48 to 20
arr<-which(data_set$Units_SH==48,arr.ind = TRUE)
data_set$Specific_SH[arr]<-data_set$Specific_SH[arr]*100
data_set$Units_SH[arr]<-20

arr<-which(data_set$Units_Geneva==48,arr.ind = TRUE)
data_set$Specific_Geneva[arr]<-data_set$Specific_Geneva[arr]*100
data_set$Units_Geneva[arr]<-20

arr<-which(data_set$Units_Annecy==48,arr.ind = TRUE)
data_set$Specific_Annecy[arr]<-data_set$Specific_Annecy[arr]*100
data_set$Units_Annecy[arr]<-20

arr<-which(data_set$Units_Torquay==48,arr.ind = TRUE)
data_set$Specific_Torquay[arr]<-data_set$Specific_Torquay[arr]*100
data_set$Units_Torquay[arr]<-20

arr<-which(data_set$Units_Geneva56_A==48,arr.ind = TRUE)
data_set$Specific_Geneva56_A[arr]<-data_set$Specific_Geneva56_A[arr]*100
data_set$Units_Geneva56_A[arr]<-20

arr<-which(data_set$Units_Geneva56_B==48,arr.ind = TRUE)
data_set$Specific_Geneva56_B[arr]<-data_set$Specific_Geneva56_B[arr]*100
data_set$Units_Geneva56_B[arr]<-20

arr<-which(data_set$Units_Geneva56_C==48,arr.ind = TRUE)
data_set$Specific_Geneva56_C[arr]<-data_set$Specific_Geneva56_C[arr]*100
data_set$Units_Geneva56_C[arr]<-20

arr<-which(data_set$Units_Dillon_A==48,arr.ind = TRUE)
data_set$Specific_Dillon_A[arr]<-data_set$Specific_Dillon_A[arr]*100
data_set$Units_Dillon_A[arr]<-20

arr<-which(data_set$Units_Dillon_B==48,arr.ind = TRUE)
data_set$Specific_Dillon_B[arr]<-data_set$Specific_Dillon_B[arr]*100
data_set$Units_Dillon_B[arr]<-20

remove(arr) #delete arr



################################################################################ Create corresponding transpose of the data_set for checking and information

colnames(data_set)[1] <- "Sched"

specific <- data_set[, c("id","Sched","Paragraph","Product","Interval","Specific_SH","Specific_Geneva","Specific_Annecy","Specific_Torquay","Specific_Geneva56_A","Specific_Geneva56_B","Specific_Geneva56_C","Specific_Dillon_A","Specific_Dillon_B")]
#specific2 <- data.frame(t(specific[,]))

ad_valorem <-data_set[,c("id","Sched","Paragraph", "Product","Interval","Ad_Valorem_SH", "Ad_Valorem_Geneva","Ad_Valorem_Annecy", "Ad_Valorem_Torquay", "Ad_Valorem_Geneva56_A", "Ad_Valorem_Geneva56_B", "Ad_Valorem_Geneva56_C","Ad_Valorem_Dillon_A", "Ad_Valorem_Dillon_B")]
#ad_valorem2<-data.frame(t(ad_valorem[,]))

#units<-data_set[, c("Sched","Paragraph","Product","Units_SH", "Units_Geneva", "Units_Annecy", "Units_Torquay", "Units_Geneva56_A", "Units_Geneva56_B", "Units_Geneva56_C", "Units_Dillon_A", "Units_Dillon_B")]
#units2<-data.frame(t(units[,]))

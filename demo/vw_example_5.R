
library(rvw)
library(ggplot2)

boston <- read.table(system.file("examples","bostonHousing","housing.data",package="rvw"),
                     col.names=c('CRIM', 'ZN', 'INDUS', 'CHAS', 'NOX', 'RM', 'AGE', 'DIS',
                                 'RAD', 'TAX', 'PTRATIO', 'B', 'LSTAT', 'y'))


set.seed(123)                           # arbitrary but fixed seed
ind_train <- sample(1:nrow(boston), 0.8*nrow(boston))  # separate train and validation data
bostonTrain <- boston[ind_train,]
bostonVal <- boston[-ind_train,]

## to not randomly leaves files behind, change to
## temporary directory of the current R session
cwd <- getwd()
setwd(tempdir())

res <- vw(training_data=bostonTrain,
          validation_data=bostonVal,
          target="y",
          loss="squared",
          link_function="--link=identity",
          keep_tempfiles=TRUE,
          do_evaluation=FALSE)


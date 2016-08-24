
library(rvw)
suppressMessages(library(ggplot2))
suppressMessages(library(pROC))
stopifnot(requireNamespace("caret", quietly=TRUE))
stopifnot(requireNamespace("randomForest", quietly=TRUE))
stopifnot(requireNamespace("party", quietly=TRUE))
stopifnot(requireNamespace("gbm", quietly=TRUE))

data("etitanic", package="earth")
dt <- dt2 <- etitanic
#dt <- read.csv("~/git/rvw/extras/titanic3.csv", quote='"', stringsAsFactors=FALSE)  ## to be made a data file
dt[, "survived"] <- ifelse(dt[, "survived"] == 1, 1, -1)

set.seed(123)                           # arbitrary but fixed seed
ind_train <- sample(1:nrow(dt), 0.8*nrow(dt))  # separate train and validation data
dt_train <- dt[ind_train,]
dt_val <- dt[-ind_train,]
dt2_train <- dt2[ind_train,]
dt2_val <- dt2[-ind_train,]

## to not randomly leaves files behind, change to
## temporary directory of the current R session
cwd <- getwd()
setwd(tempdir())

## use data directly
resvw <- vw(training_data = dt_train,
            validation_data = dt_val,
            target = "survived",
            use_perf = rvw:::getPerf() != "",
            passes = 10,
            keep_tempfiles=TRUE,
            verbose = TRUE)
resvw[["data"]][, actual:=as.factor(dt_val$survived)]
dd <- resvw[["data"]]
setwd(cwd)                              # go back

caret::confusionMatrix(ifelse(resvw[["data"]][,predicted] >= 0.5, 1, -1), resvw[["data"]][,actual])

rvw:::plotDensity(resvw[["data"]])   ## TODO: plot method of a class vw

rocvw <- roc(dd[,actual], dd[, predicted])
plot(rocvw)


## glm
resglm <- glm(survived ~ pclass + sex + age + sibsp + parch, family = binomial(logit), data = dt2_train)
predglm <- predict(resglm, dt2_val, type="response")
caret::confusionMatrix(ifelse(predglm >= 0.5, 1, 0), dt2_val$survived)
rocglm <- roc(dd[,actual], predglm)
plot(rocglm, col="orange", add=TRUE)


## rf
resrf <- randomForest::randomForest(as.factor(survived) ~ pclass + sex + age + sibsp + parch,
                                    data=dt_train,
                                    ntree=5000, importance=TRUE, keep.forest=TRUE)
predrf <- predict(resrf, dt_val)
predrfprob <- predict(resrf, dt_val, type="prob")
caret::confusionMatrix(as.integer(as.character(predrf)), dt_val$survived)
rocrf <- roc(dd[,actual], predrfprob[,1])
plot(rocrf, col="blue", add=TRUE)

## party
resparty <- party::ctree(as.factor(survived) ~ pclass + sex + age + sibsp + parch,
                         data=dt_train)
predparty <- predict(resparty, dt_val, type="prob")
predparty <- do.call(rbind, lapply(predparty, "[[", 1))
rocparty <- roc(dd[,actual], predparty[,1])
plot(rocparty, col="yellow", add=TRUE)


## gbm
resgbm <- gbm::gbm(as.factor(survived) ~ pclass + sex + age + sibsp + parch,
                   distribution="bernoulli", data=dt2_train, n.trees=500)


legend("bottomright", 
       legend=c("vw", "glm", "rf", "ctree"), 
       col=c("black","orange","blue", "yellow"),bty="n",lwd=2)



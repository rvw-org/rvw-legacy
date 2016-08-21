
library(rvw)
library(ggplot2)

data("etitanic", package="earth")
dt <- etitanic
#dt <- read.csv("~/git/rvw/extras/titanic3.csv", quote='"', stringsAsFactors=FALSE)  ## to be made a data file


set.seed(123)                           # arbitrary but fixed seed
ind_train <- sample(1:nrow(dt), 0.8*nrow(dt))  # separate train and validation data
dt_train <- dt[ind_train,]
dt_val <- dt[-ind_train,]

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
            verbose = TRUE)
resvw[["data"]][, actual:=as.factor(dt_val$survived)]
dd <- resvw[["data"]]
setwd(cwd)                              # go back

if (requireNamespace("caret", quietly=TRUE)) {
    caret::confusionMatrix(ifelse(resvw[["data"]][,predicted] >= 0.5, 1, 0), resvw[["data"]][,actual])
}

rvw:::plotDensity(resvw[["data"]])   ## TODO: plot method of a class vw

rocvw <- roc(dd[,actual], dd[, predicted])
plot(rocvw)


## glm
resglm <- glm(survived ~ pclass + sex + age + sibsp + parch, family = binomial(logit), data = dt_train)
predglm <- predict(resglm, dt_val, type="response")
if (requireNamespace("caret", quietly=TRUE)) {
    caret::confusionMatrix(ifelse(predglm >= 0.5, 1, 0), dt_val$survived)
}
rocglm <- roc(dd[,actual], predglm)
plot(rocglm, col="orange", add=TRUE)


## rf
if (requireNamespace("randomForest", quietly=TRUE)) {
    library(randomForest)
    resrf <- randomForest(as.factor(survived) ~ pclass + sex + age + sibsp + parch, data=dt_train,
                          ntree=5000, importance=TRUE, keep.forest=TRUE)
    predrf <- predict(resrf, dt_val)
    predrfprob <- predict(resrf, dt_val, type="prob")
    if (requireNamespace("caret", quietly=TRUE)) {
        caret::confusionMatrix(as.integer(as.character(predrf)), dt_val$survived)
    }
    rocrf <- roc(dd[,actual], predrfprob[,1])
    plot(rocrf, col="blue", add=TRUE)

}



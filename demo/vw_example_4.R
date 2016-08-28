
library(rvw)
suppressMessages(library(ggplot2))
suppressMessages(library(pROC))
stopifnot(requireNamespace("caret", quietly=TRUE))
stopifnot(requireNamespace("randomForest", quietly=TRUE))
stopifnot(requireNamespace("party", quietly=TRUE))
stopifnot(requireNamespace("gbm", quietly=TRUE))
stopifnot(requireNamespace("xgboost", quietly=TRUE))

stopifnot(requireNamespace("RColorBrewer", quietly=TRUE))
cols <- rev(RColorBrewer::brewer.pal(9, "Blues"))

data("etitanic", package="earth")
dt <- dt2 <- etitanic
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

print(confvw <- caret::confusionMatrix(ifelse(resvw[["data"]][,predicted] >= 0.5, 1, -1), resvw[["data"]][,actual]))

rvw:::plotDensity(resvw[["data"]])   ## TODO: plot method of a class vw

rocvw <- roc(dd[,actual], dd[, predicted])
plot(rocvw, col=cols[1])


## glm
resglm <- glm(survived ~ pclass + sex + age + sibsp + parch, family = binomial(logit), data = dt2_train)
predglm <- predict(resglm, dt2_val, type="response")
print(confglm <- caret::confusionMatrix(ifelse(predglm >= 0.5, 1, 0), dt2_val$survived))
rocglm <- roc(dd[,actual], predglm)
plot(rocglm, col=cols[2], add=TRUE)


## rf
resrf <- randomForest::randomForest(as.factor(survived) ~ pclass + sex + age + sibsp + parch,
                                    data=dt_train,
                                    ntree=5000, importance=TRUE, keep.forest=TRUE)
predrf <- predict(resrf, dt_val)
predrfprob <- predict(resrf, dt_val, type="prob")
print(confrf <- caret::confusionMatrix(as.integer(as.character(predrf)), dt_val$survived))
rocrf <- roc(dd[,actual], predrfprob[,1])
plot(rocrf, col=cols[3], add=TRUE)

## party
resparty <- party::ctree(as.factor(survived) ~ pclass + sex + age + sibsp + parch,
                         data=dt_train)
predparty <- predict(resparty, dt_val, type="prob")
predparty <- do.call(rbind, lapply(predparty, "[[", 1))
print(confparty <- caret::confusionMatrix(ifelse(predparty <= 0.5, 1, -1), dt_val$survived))
rocparty <- roc(dd[,actual], predparty[,1])
plot(rocparty, col=cols[4], add=TRUE)


## gbm
resgbm <- gbm::gbm(survived ~ pclass + sex + age + sibsp + parch,
                   distribution="bernoulli", data=dt2_train, n.trees=500)
predgbm <- predict(resgbm, dt2_val, n.trees=500, type="response")
print(confgbm <- caret::confusionMatrix(ifelse(predgbm >= 0.5, 1, -1), dt_val$survived))
rocgbm <- roc(dd[,actual], predgbm)
plot(rocgbm, col=cols[5], add=TRUE)


## xgboost
dt_train_dgc <- Matrix::sparse.model.matrix(survived ~ . - 1, data=dt_train)
dt_val_dgc <- Matrix::sparse.model.matrix(survived ~ . - 1, data=dt_val)
targetvector <- data.table::data.table(dt_train)[, Y:=0][survived==1, Y:=1][,Y]
resxgboost <- xgboost::xgboost(data = dt_train_dgc, label=targetvector,
                               objective="binary:logistic", nrounds=25, eta=0.75, max.depth=5, 
                               verbose=0)
predxgboost <- xgboost::predict(resxgboost, dt_val_dgc)
print(confxgboost <- caret::confusionMatrix(ifelse(predxgboost >= 0.5, 1, -1), dt_val$survived))
rocxgboost <- roc(dd[,actual], predxgboost)
plot(rocxgboost, col=cols[6], add=TRUE)

legend("bottomright",
       legend=c(paste("vw",      format(as.numeric(rocvw$auc), digits=4)), 
                paste("glm",     format(as.numeric(rocglm$auc), digits=4)),
                paste("rf",      format(as.numeric(rocrf$auc), digits=4)),
                paste("ctree",   format(as.numeric(rocparty$auc), digits=4)),
                paste("gbm",     format(as.numeric(rocgbm$auc), digits=4)),
                paste("xgboost", format(as.numeric(rocxgboost$auc), digits=4))),
       col=cols[1:6], bty="n", lwd=2)

## testProbs <- data.frame(obs = dd[,actual],
##                         vw = dd[, predicted],
##                         glm = predglm,
##                         rf = predrfprob[,1],
##                         ctree = predparty[,1])
## calplotData <- caret::calibration(obs ~ vw + glm + rf + ctree, data=testProbs)
## lattice::xyplot(calplotData, auto.key=list(columns=2))
## ggplot(calplotData, bwidth=2, dwidth=3)


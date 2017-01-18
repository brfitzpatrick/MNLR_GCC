
# load the data prepared in Data_Preparation.R:

load('~/MNLR_GCC/Data/Filtered_Data.RData')

# load the packages we will use:

library(dplyr)

# read about `dplyr` here: <http://r4ds.had.co.nz/transform.html>

library(glmnet)

# read about `glmnet` here: <https://cran.r-project.org/web/packages/glmnet/vignettes/glmnet_beta.html>

library(caret)

# read about `caret` here: <http://topepo.github.io/caret/index.html>

# we'll use `caret` with parallel processing provided by `doMC`

library(doMC)

registerDoMC(cores = 6)

# create cross validation folds that have proportions of the different crops as balanced as possible
# (recall our rarest crop classes now have > 1e3 observations)

# set the number of cross validation folds
n.folds <- 5

cv.k.f <- createFolds(y = Data$crop.c, k = 10, returnTrain = TRUE)

class(cv.k.f)

# e.g.

Data %>%
  slice(cv.k.f[[1]]) %>%
    group_by(crop.c) %>%
      summarise(count = n())

# at least all crop classes have > 1000 observations in the training set

# do test run of glmnet with alpha = 1 and set lambda sequence length to get the glmnet recommended lambda sequence

system.time(m.test <- glmnet(x = as.matrix(select(.data = Data, -crop.c)), y = Data$crop.c, family = 'multinomial', alpha = 1, nlambda = 1e3)) # 15 mins

summary(m.test)

summary(m.test$lambda) # min = 3.399e-05, max = 2.775e-01 

trCtrl <- trainControl(index = cv.k.f)

seq.leng <- 10

tunning.grid <- expand.grid(alpha = seq(from = 0, to = 1, length.out = seq.leng),
                            lambda = seq(from = min(m.test$lambda), to = max(m.test$lambda), length.out = seq.leng))

system.time(
  train.obj <- train(x = as.matrix(select(.data = Data, -crop.c)),
                  y = Data$crop.c,
                  trControl = trCtrl,
                  method = 'glmnet',
                  tuneGrid = tunning.grid)
)

save.image(file = '~/MNLR_GCC/Data/Fit.RData')

class(train.obj$finalModel)

# Overall predictive accuracy:

y.hat <- predict.glmnet(object = train.obj$finalModel, newx = as.matrix(select(.data = Data, -crop.c)))

# number of correct predictions
summary(y.hat == Data$crop.c)

# % of correct predictions                   
100*length(y.hat[y.hat == Data$crop.c])/length(Data$crop.c) # ?? previously 78.16 % of predictions are correct

# distribution of correct predictions:                   
round(100*summary(factor(y.hat[y.hat == Data$crop.c])) / summary(factor(Data$crop.c)), digits = 1)


Pred.Objs <- data.frame(Prediction = y.hat, Observation = Data$crop.c)

sum(Pred.Objs$Observation == Pred.Objs$Prediction)/nrow(Pred.Objs)

# overall % of pixels predicted correctly:
Pred.Objs %>%
  mutate(Correct = (Prediction == Observation)) %>%
    summarise(100*sum(Correct)/n())

# % of pixels in each crop category predicted correctly:
Pred.Objs %>%
  mutate(Correct = (Prediction == Observation)) %>%
    group_by(Observation) %>%
      summarise(Percnt.Correct = 100*sum(Correct)/n())

# but see also

confusionMatrix(data = y.hat, reference = Data$crop.c, mode = 'prec_recall')

# and

postResample(pred = y.hat, obs = Data$crop.c)

# previously:

# % correct predictions
#  Bare_soil & Cotton & Maize & Pasture_natural & Peanut & Sorghum & Wheat \\
#       91.0 &   92.2 &  14.2 &            77.6 &   82.9 &    80.3 &  10.3 \\

# Wheat and Maize are the two categories with the least observation

# the next step would be to examine the performance on some data held out from the cross validation scheme entirely
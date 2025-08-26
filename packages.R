required_packages = c("rsconnect", "rmarkdown", "knitr", "caret", "corrplot", "dplyr", "naivebayes", "pROC",      
             "rsample", "tidyr" , "mlflow", "carrier", "randomForest", "plumber")

install.packages(setdiff(required_packages, rownames(installed.packages())))

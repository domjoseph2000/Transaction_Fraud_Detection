# plumber.R
library(plumber)
library(naivebayes)
#library(randomForest)

# Load model once at startup
model <- readRDS("fraud_model.rds")

#* Health check
#* @get /ping
function() {
  list(status = "alive")
}

#* Predict fraud probability
#* @param log_amount:numeric Transaction amount (log-transformed already)
#* @param gender:string Customer gender
#* @param mod_age:string Age group bucket
#* @param mod_category:string Category bucket
#* @post /predict
function(log_amount, gender, mod_age, mod_category) {
  
  # Construct input data.frame
  new_data <- data.frame(
    log_amount   = as.numeric(log_amount),
    gender       = as.character(gender),
    mod_age      = as.character(mod_age),
    mod_category = as.character(mod_category)
  )
  
  # Predict fraud probability
  prob <- stats::predict(model, newdata = new_data, type = "prob")[, "1"]
  
  list(
    fraud_probability = prob
  )
}
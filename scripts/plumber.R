# plumber.R
library(plumber)
library(naivebayes)
library(dplyr)
library(randomForest)

# Load model once at startup
model <- readRDS("fraud_model.rds")

#* Health check
#* @get /ping
function() {
  list(status = "alive")
}

#* Predict fraud probability
#* @param amount:numeric Transaction amount.

#* @param gender:string Customer gender.
#*        Allowed values:
#*        - M = Male
#*        - F = Female
#*        - E = Enterprise
#*        - U = Unknown

#* @param age:string Age group bucket.
#*        Allowed values:
#*        - 0 = <= 18
#*        - 1 = 19–25
#*        - 2 = 26–35
#*        - 3 = 36–45
#*        - 4 = 46–55
#*        - 5 = 56–65
#*        - 6 = > 65
#*        - U = Unknown

#* @param category:string Category bucket.
#*        Allowed values:
#*        - es_leisure       = Entertainment  
#*        - es_hotelservices = Hotel Services  
#*        - es_home          = Household  
#*        - es_travel        = Travel-related  
#*        - es_health        = Health services  
#*        - es_sportsandtoys = Sports and Toys  
#*        - es_otherservices = Other spending

#* @post /predict
function(amount, gender, age, category) {
  
  # Construct input data.frame
  new_data <- data.frame(
    amount       = as.numeric(amount),
    gender       = as.character(gender),
    age          = as.character(age),
    category     = as.character(category)
  )
  
  transformed_data = new_data %>% 
    dplyr::mutate(
      log_amount = log(amount),
      mod_age = case_when(age %in% c('1','2','3','4','5','U') ~ '1-5',
                          TRUE ~ age
      ),
      mod_category = case_when(category %in% c('es_leisure', 
                                               'es_hotelservices', 
                                               'es_home', 
                                               'es_sportsandtoys', 
                                               'es_travel', 
                                               'es_otherservices', 
                                               'es_health') ~ category,
                               TRUE ~ 'es_misc')
    )
  transformed_data <- transformed_data[, c("log_amount", "gender", "mod_age", "mod_category")]
  
  # prediction_helper.R
  predict_fraud <- function(model, transformed_data) {
    if (inherits(model, "naiveBayes")) {
      
      # naiveBayes probability
      prob <- predict(model, newdata = transformed_data, type = "prob")[, "1"]
      
    } else if (inherits(model, "glm") && family(model)$family == "binomial") {
      # logistic regression probability
      prob <- predict(model, newdata = transformed_data, type = "response")
      
    } else if (inherits(model, "randomForest")) {
      prob <- predict(model, newdata = transformed_data, type = "prob")[, "1"]
      
    } else {
      stop("Unsupported model type")
    }
    return(prob)
  }
  
  # Predict fraud probability
  prob <- predict_fraud(model, transformed_data)
  
  list(
    fraud_probability = prob
  )
}
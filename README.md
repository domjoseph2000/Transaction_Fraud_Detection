# **Fraud Detection on Bank Payments**

This synthetically generated dataset consists of payments from various customers made in different time periods and with different amounts. For more information on the dataset you can check the Kaggle page for this dataset:

[https://www.kaggle.com/code/turkayavci/fraud-detection-on-bank-payments/notebook]

The goal of this exercise is to fit different machine learning models on the data to see which one performs better, while tracking the model runs in MLflow (confusion matrix, ROC plots, performance metrics, model objects etc). Final champion model is selected based on various performance metrics and promoted to production environment. The champion model is also deployed using a REST api with the help of Docker. 

The modelling procedure follows the following main steps.

* Data Analysis and Feature Engineering

    * Univariate analysis.
    * Bivariate analysis.
    * Feature engineering.

* Model Fitting and Selection

    * Create train-test split
    * Fitting 3 candidate base models:
        - Logistic Regression
        - Naive Bayes
        - Random Forest
    * Performance evaluation (ROC, F1) and model tracking (MLFlow)

* Model Deployment using Docker

In the modelling stage, the model is trained using different ML classifier algorthms. The model training and evaluation are tracked and logged using `MLFlow`. Out of the different models, appropriate champion model is selected and then promoted to Production. 

## Steps to Run the File

### Run RMD file


1. Extract the zip file `data/bs140513_032310.7z`, which is the data for the R file.

2. Run `analysis/DataAnalysis_and_FeatureEngineering.RMD` file, to understand the initial data analysis steps.The file also installs all the required packages for you before performing further analysis of the project. Alternately, you can open and run `renv-setup.R` first before running the .RMD file, if you wish to run and manage the project as an renv project.
3. Run `analysis/ModelSelection.RMD` file, where the different modelling techniques are applied on the model development dataset. This stage employs the use of `MLflow` package. Since `MLflow` in R is a api to the corresponding Python package, you need to create a python environment with Python MLFlow version installed in it.

4. Once the models are all succesfully run, open the MLflow UI and promote the required model (based on performance or other evaluation criteria) to `Production`. Alsomake sure to tag the final version of production model as `prod`.

5. Once the models are in production, run the`Download_RDS_Artifact.RMD` file to download the model artifact to `./data` folder for further deployment. There are multiple ways to serve a model for prediction. The method followed in this exercise used Plumber + Docker (see next section) to containerise and serve the model.

6. Image for running the docker-container is specified in `./Dockerfile`. It calls a A Plumber API script, which is an R script (.R) that uses special comments to turn your R functions into live web API endpoints. 

### Model Deployment with Docker + Plumber	        	

This method lets you deploy the prediction model based on model artifact as a REST api, using `plumber` package. This involves the running a dockerfile whch calls a plumber API script. The api script is in `scripts/plumber.R`. It’s the easiest way to make your R code, like a predictive model or a data processing function, accessible over a network. You may need to install docker on your computer (if not done already).

1. Navigate to the project folder location
cd 'A:/path/to/your/Fraud Detection'

2. Build docker image

`docker build -t <image-name> -f ./Dockerfile .` 

3. Run docker container

`docker run --rm -it -p 8000:8000 <image-name>`

4. Once the container runs, the API will be accessible from `http://127.0.0.1:8000/__docs__/` which displays an interactve web-ui for inputting the raw parameters for prediction.


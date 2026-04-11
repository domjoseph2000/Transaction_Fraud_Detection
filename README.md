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

### Install Python and Mlflow Python Package

The following steps need to be performed independently outside of R console or Rstudio before the analysis and model runs.

MLflow R package is actually a "wrapper" around the Python process running in the background. So we need to install python and create a virtual environment where we install python `mlflow` package

-	Install python version and create the venv.
	
		`python -m venv A:\path-to-venv-folder\mlflow_venv`
		
-	Activate your venv.
	
		`A:\path-to-venv-folder\mlflow_venv\Scripts\activate`
		
-	Install mlflow python package in your venv.
		
		`pip install mlflow`
	
Edit the system environment variables and add `MLFLOW_BIN` and `MLFLOW_PYTHON_BIN`  environment variables. These are used by the MLflow R client to locate your Python and MLflow installations.

-	*MLFLOW_PYTHON_BIN*: Points to the path of the Python executable (`A:\path-to-venv-folder\mlflow_venv\Scripts\mlflow.exe`). It ensures R uses the exact version of Python where your packages are installed.
	
-	*MLFLOW_BIN*: Points to the path of the MLflow CLI executable (`A:\path-to-venv-folder\mlflow_venv\Scripts\python.exe`). This allows R to trigger MLflow commands (like starting the UI or logging models) directly.

### Run Analysis

1.	Extract the zip file `data/bs140513_032310.7z`, which is the data for the R file.

2.	Run `analysis/DataAnalysis_and_FeatureEngineering.RMD` file, to understand the initial data analysis steps. The file also installs all the required packages for you before performing further analysis of the project. Alternately, you can open and run `renv-setup.R` first before running the .RMD file, if you wish to run and manage the project as an renv project.

3.	You can visualise the distribution of data at univariate level and also across categories. The stage also covers feature engineering based on observed patterns and relationship with dependent variable.

5.	You can also generate the output of this file by knitting it as an .html or .pdf file for future reference.


### Model Selection a Mlflow Tracking

1.	Run `analysis/ModelSelection.RMD` file, where the different modelling techniques are applied on the model development dataset. This stage employs the use of `MLflow` package. Since `MLflow` in R is a api to the corresponding Python package, you need to ensure that you follow the steps in the previous section and create a python environment with Python MLFlow version installed in it.

2.	Before creating the experiment and tracking the models, first, you need to start the mlflow tracking server, specify the URI scheme (file:///) for the server and backend store. In a terminal, start the server by pointing to your existing backend (Create a directory for example `C:/Users/username/mlflow-backend` if you have to):
	Run the below lines in command line:
	```
	mlflow server --host 127.0.0.1 --port 5000 --backend-store-uri "file:///A:/<path-to-project>/mlruns" --default-artifact-root "file:///A:/<path-to-project>/mlruns"
		
	```
	The `file:///` prefix tells MLflow that you are using a Local Backend Store for storing artifacts. It also launches the UI & starts the web dashboard that you can view at http://127.0.0.1:5000.
	
	Note: R's mlflow package is often tied to specific versions of the MLflow Python library. An environment lets you pin the exact version that matches your R package to avoid compatibility errors.

3.	After this is succesful, in the R script, we specify a tracking uri `mlflow_set_tracking_uri("http://127.0.0.1:5000")`. It tells R to send data to the running MLflow server which we created earlier. 

4.	Then, the code creates an MLflow experiment (eg `Fraud-Detection-MLmodels`) and you can run each model one by one under the experiment. During each model run, the experiment logs the model performance metrics, plots and also the model predictor function as model artifact of each model. Note that the model prediction object is created using  using `carrier::crate()`. This wraps the model's predict method in a standard format. 

5.	Once the models are all succesfully run and experiment is complete, open the MLflow UI to view the model parameters and compare the results and plots. You can promote the required model (based on performance or other evaluation criteria) to `Production`. Also make sure to tag the final version of production model as `prod`.

6.	Once the models are in production, run the`Download_RDS_Artifact.RMD` file to download the corresponding model object artifact to `./data` folder for further deployment. There are multiple ways to serve a model for prediction. The method followed in this exercise used Plumber + Docker (see next section) to containerise and serve the model.

7.	Image for running the docker-container is specified in `./Dockerfile`. It calls a A Plumber API script, which is an R script (.R) that uses special comments to turn your R functions into live web API endpoints. 

### Model Deployment with Docker + Plumber	        	

This method lets you deploy the prediction model based on model artifact as a REST api, using `plumber` package. This involves the running a dockerfile whch calls a plumber API script. The api script is in `scripts/plumber.R`. It’s the easiest way to make your R code, like a predictive model or a data processing function, accessible over a network. You may need to install docker on your computer (if not done already).

1. Navigate to the project folder location
cd 'A:/path/to/your/Fraud Detection'

2. Build docker image

	`docker build -t <image-name> -f ./Dockerfile .` 

3. Run docker container

	`docker run --rm -it -p 8000:8000 <image-name>`

4. Once the container runs, the API will be accessible from `http://127.0.0.1:8000/__docs__/` which displays an interactve web-ui for inputting the raw parameters for prediction.


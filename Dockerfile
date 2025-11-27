# Use official R base image
FROM rocker/r-ver:4.5.0

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libsodium-dev \
    zlib1g-dev \
    build-essential \
    pkg-config \
    git \
    && rm -rf /var/lib/apt/lists/*
	

# Copy API script and model into container
WORKDIR /app
# Copy the API script
COPY scripts/plumber.R .
# Copy the model object
COPY data/fraud_model.rds .
# Copy renv lockfile
#COPY renv.lock .

# Install required R packages
#RUN R -e "install.packages('renv')"
#RUN R -e "Sys.setenv(RENV_CONFIGURE_ARGS='--no-interactive'); options(repos=c(CRAN='https://cloud.r-project.org')); renv::restore()"

RUN R -e "install.packages('remotes', repos='https://cloud.r-project.org')"

RUN R -e "remotes::install_version('plumber', version='1.3.0', repos='https://cloud.r-project.org')"
RUN R -e "remotes::install_version('dplyr', version='1.1.4', repos='https://cloud.r-project.org')"
RUN R -e "remotes::install_version('naivebayes', version='1.0.0', repos='https://cloud.r-project.org')"
RUN R -e "remotes::install_version('randomForest', version='4.7.1.2', repos='https://cloud.r-project.org')"


# Remove build dependencies after install
RUN apt-get purge -y build-essential git pkg-config \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*


# Expose port
EXPOSE 8000

# Run plumber API
CMD ["Rscript", "-e", "library(plumber); pr <- plumber::plumb('plumber.R'); pr$run(host='0.0.0.0', port=8000)"]

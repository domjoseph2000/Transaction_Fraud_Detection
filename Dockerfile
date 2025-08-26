# Use official R base image
FROM rocker/r-ver:4.5.0

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*
	

# Copy API script and model into container
WORKDIR /app
COPY scripts/plumber.R .
COPY data/fraud_model.rds .

# Install required R packages
RUN R -e "install.packages(c('plumber', 'naivebayes'))"

# Expose port
EXPOSE 8000

# Run plumber API
CMD ["Rscript", "-e", "library(plumber); pr <- plumber::plumb('plumber.R'); pr$run(host='0.0.0.0', port=8000)"]

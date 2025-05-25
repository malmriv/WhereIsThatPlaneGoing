FROM rstudio/plumber

# Install R packages
COPY requirements.txt /tmp/
RUN R -e "packages <- readLines('/tmp/requirements.txt'); install.packages(packages, repos='https://cloud.r-project.org')"

# Copy app
COPY . /app
WORKDIR /app

# Run Plumber app
CMD ["Rscript", "plumber.R"]
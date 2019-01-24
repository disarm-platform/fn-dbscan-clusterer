FROM r-base

COPY function/install_packages.R .
RUN 'Rscript function/install_packages.R'

ENV fprocess = 'Rscript main.R'

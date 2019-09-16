#!/bin/bash
# INSTALA DEPENDENCIAS RSERVE
sudo R -e 'dir.create(Sys.getenv("R_LIBS_USER"), recursive = TRUE)'
sudo R -e '.libPaths(Sys.getenv("R_LIBS_USER"))'
sudo R -e 'install.packages(c("R2HTML", "rjson", "DescTools", "Rserve", "haven"), lib="/usr/local/lib/R/site-library", repos="https://cloud.r-project.org/")'
# sudo -i R
# dir.create(Sys.getenv("R_LIBS_USER"), recursive = TRUE) 
# .libPaths(Sys.getenv("R_LIBS_USER"))
# install.packages("R2HTML", repos="https://cloud.r-project.org/" )
# install.packages("rjson", repos="https://cloud.r-project.org/" )
# install.packages("DescTools", repos="https://cloud.r-project.org/" )
# install.packages("Rserve", repos="https://cloud.r-project.org/" )
# install.packages("haven", repos="https://cloud.r-project.org/" )
# q()
# n
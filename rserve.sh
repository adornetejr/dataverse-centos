#!/bin/bash
# INSTALA DEPENDENCIAS RSERVE
sudo -i R
dir.create(Sys.getenv("R_LIBS_USER"), recursive = TRUE) 
.libPaths(Sys.getenv("R_LIBS_USER")) 
install.packages("R2HTML", repos="https://cloud.r-project.org/" )
install.packages("rjson", repos="https://cloud.r-project.org/" )
install.packages("DescTools", repos="https://cloud.r-project.org/" )
install.packages("Rserve", repos="https://cloud.r-project.org/" )
install.packages("haven", repos="https://cloud.r-project.org/" )
q()
n
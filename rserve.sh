#!/bin/bash
DIR=$PWD
systemctl stop rserve
yum install -y R R-core R-core-devel
# INSTALA DEPENDENCIAS RSERVE
sudo R -e 'dir.create(Sys.getenv("R_LIBS_USER"), recursive = TRUE)'
sudo R -e '.libPaths(Sys.getenv("R_LIBS_USER"))'
sudo R -e 'install.packages(c("R2HTML", "rjson", "DescTools", "Rserve", "haven"), repos="https://cloud.r-project.org/")'
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
useradd rserve
rm -f /usr/lib/systemd/system/rserve.service
cp $DIR/rserve.service /usr/lib/systemd/system/
systemctl daemon-reload
echo "RSERVE_HOST	127.0.0.1" >> default.config
echo "RSERVE_PORT	6311" >> default.config
echo "RSERVE_USER	rserve" >> default.config
echo "RSERVE_PASSWORD	rserve" >> default.config
echo "Starting rserve!"
systemctl enable rserve
systemctl start rserve
# STATUS DO SERVICO RSERVE
systemctl status rserve
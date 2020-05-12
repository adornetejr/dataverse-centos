#!/bin/bash
DIR=$PWD
echo "Parando Rserve!"
systemctl stop rserve
echo "Removendo configurações antigas!"
TIMESTAMP=$(date "+%Y.%m.%d-%H.%M.%S")
mv /home/rserve/R /home/rserve/R-$TIMESTAMP
echo "Instalando R!"
yum install -y R R-core R-core-devel
echo "Configurando R!"
# INSTALA DEPENDENCIAS RSERVE
useradd rserve
sudo -S -u rserve R -e 'dir.create(Sys.getenv("R_LIBS_USER"), recursive = TRUE)'
sudo -S -u rserve R -e '.libPaths(Sys.getenv("R_LIBS_USER"))'
R -e 'install.packages(c("R2HTML", "rjson", "DescTools", "Rserve", "haven"), repos="https://cloud.r-project.org/")'
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
echo "RSERVE_HOST	localhost" >>$DIR/default.config
echo "RSERVE_PORT	6311" >>$DIR/default.config
echo "RSERVE_USER	rserve" >>$DIR/default.config
echo "RSERVE_PASSWORD	rserve" >>$DIR/default.config
# SERVIÇO RSERVE
mv /usr/lib/systemd/system/rserve.service /usr/lib/systemd/system/rserve.service.bkp
cp $DIR/service/rserve.service /usr/lib/systemd/system/rserve.service
systemctl daemon-reload
# START RSERVE
echo "Habilitando Rserve para iniciar com o sistema!"
systemctl enable rserve
echo "Iniciando Rserve!"
systemctl start rserve
# STATUS DO SERVICO RSERVE
systemctl status rserve
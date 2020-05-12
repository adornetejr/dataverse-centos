#!/bin/bash
DIR=$PWD
RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`
echo "${GREEN}Stopping Rserve!${RESET}"
systemctl stop rserve
echo "${GREEN}Removing old settings!${RESET}"
TIMESTAMP=$(date "+%Y.%m.%d-%H.%M.%S")
mv /home/rserve/R /home/rserve/R-$TIMESTAMP
echo "${GREEN}Installing R!${RESET}"
yum install -y R R-core R-core-devel
echo "${GREEN}Setting up R!${RESET}"
# RSERVE DEPENDENCIES
useradd rserve
usermod -s /sbin/nologin rserve
sudo -S -u rserve R -e 'dir.create(Sys.getenv("R_LIBS_USER"), recursive = TRUE)'
sudo -S -u rserve R -e '.libPaths(Sys.getenv("R_LIBS_USER"))'
R -e 'install.packages(c("R2HTML", "rjson", "DescTools", "Rserve", "haven"), repos="https://cloud.r-project.org/")'
echo "RSERVE_HOST	localhost" >>$DIR/default.config
echo "RSERVE_PORT	6311" >>$DIR/default.config
echo "RSERVE_USER	rserve" >>$DIR/default.config
echo "RSERVE_PASSWORD	rserve" >>$DIR/default.config
# RSERVE SERVICE
mv /usr/lib/systemd/system/rserve.service /usr/lib/systemd/system/rserve.service.bkp
cp $DIR/service/rserve.service /usr/lib/systemd/system/rserve.service
systemctl daemon-reload
# RSERVE SYSTEM START
echo "${GREEN}Enabling Rserve to start with the system!${RESET}"
systemctl enable rserve
echo "${GREEN}Starting Rserve!${RESET}"
systemctl start rserve
# SERVICE RSERVE STATUS
echo "${GREEN}Rserve status!${RESET}"
systemctl status rserve
#!/bin/bash
DIR=$PWD
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)
echo "${GREEN}Stopping Rserve!${RESET}"
sudo systemctl stop rserve
echo "${GREEN}Backing up old installation!${RESET}"
TIMESTAMP=$(date "+%Y.%m.%d-%H.%M.%S")
# mv /home/rserve/R $DIR/backup/R-$TIMESTAMP
echo "${GREEN}Installing dependencies!${RESET}"
yum install -y R R-core R-core-devel
echo "${GREEN}Setting up R!${RESET}"
# RSERVE DEPENDENCIES
useradd rserve
usermod -s /sbin/nologin rserve
sudo -S -u rserve R -e 'dir.create(Sys.getenv("R_LIBS_USER"), recursive = TRUE)'
sudo -S -u rserve R -e '.libPaths(Sys.getenv("R_LIBS_USER"))'
echo "${GREEN}Installing R packages${RESET}"
# R -e 'install.packages(c("R2HTML", "rjson", "DescTools", "Rserve", "haven"), repos="https://cloud.r-project.org/")'
echo "${GREEN}Installing R2HTML${RESET}"
R -e 'install.packages(c("R2HTML"), repos="https://cloud.r-project.org/")'
echo "${GREEN}Installing rjson${RESET}"
R -e 'install.packages(c("rjson"), repos="https://cloud.r-project.org/")'
echo "${GREEN}Installing DescTools${RESET}"
R -e 'install.packages(c(DescTools"), repos="https://cloud.r-project.org/")'
echo "${GREEN}Installing haven${RESET}"
R -e 'install.packages(c(haven"), repos="https://cloud.r-project.org/")'
echo "${GREEN}Installing Rserve${RESET}"
R -e 'install.packages(c("Rserve"), repos="https://cloud.r-project.org/")'
echo "RSERVE_HOST	localhost" >>$DIR/default.config
echo "RSERVE_PORT	6311" >>$DIR/default.config
echo "RSERVE_USER	rserve" >>$DIR/default.config
echo "RSERVE_PASSWORD	rserve" >>$DIR/default.config
# RSERVE SERVICE
mv /usr/lib/systemd/system/rserve.service /usr/lib/systemd/system/rserve.service.bkp
cp $DIR/service/rserve.service /usr/lib/systemd/system/rserve.service
sudo systemctl daemon-reload
# RSERVE SYSTEM START
echo "${GREEN}Enabling Rserve to start with the system!${RESET}"
sudo systemctl enable rserve
echo "${GREEN}Starting Rserve!${RESET}"
sudo systemctl start rserve
sleep 4
# SERVICE RSERVE STATUS
echo "${GREEN}Rserve status!${RESET}"
sudo systemctl status rserve
echo " "
echo "${GREEN}Rserve installed!${RESET}"
echo "Stage (5/11) done!"
echo "${RED}Ctrl+C${RESET} to stop or ${GREEN}Enter${RESET} to continue!"
# read -e $X
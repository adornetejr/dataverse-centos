#!/bin/bash
DIR=$PWD
echo "Stopping Rserve!"
systemctl stop rserve
echo "Removing old settings!"
TIMESTAMP=$(date "+%Y.%m.%d-%H.%M.%S")
mv /home/rserve/R /home/rserve/R-$TIMESTAMP
echo "Installing R!"
yum install -y R R-core R-core-devel
echo "Setting up R!"
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
echo "Enabling Rserve to start with the system!"
systemctl enable rserve
echo "Starting Rserve!"
systemctl start rserve
# SERVICE RSERVE STATUS
systemctl status rserve
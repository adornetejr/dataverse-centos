#!/bin/bash
DIR=$PWD
RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`
echo "${GREEN}Backing up old installation!${RESET}"
TIMESTAMP=$(date "+%Y.%m.%d-%H.%M.%S")
/bin/cp -R /usr/local/counter-processor $DIR/backup/counter-processor-$TIMESTAMP
echo "${GREEN}Removing old settings!${RESET}"
rm -rf /tmp/counter-processor-0.0.1
# INSTALL COUNTER DEPENDENCIES
echo "${GREEN}Installing dependencies!${RESET}"
yum install -y python36
echo "${GREEN}Downloading Counter-Processor!${RESET}"
FILE="v0.0.1.tar.gz"
LOCATION="/tmp/$FILE"
LINK=https://github.com/CDLUC3/counter-processor/archive/v0.0.1.tar.gz
if [ -f "$LOCATION" ]; then
    ls $LOCATION
    if [ "$(md5sum $LOCATION)" == "25ffe6a101675ec51439db40172f2424  $LOCATION" ]; then
        tar xvfz $LOCATION -C /tmp
    else
        rm $LOCATION
        wget $LINK -P /tmp
        tar xvfz $LOCATION -C /tmp
    fi
else
    wget $LINK -P /tmp
    tar xvfz $LOCATION -C /tmp
fi
echo "${GREEN}Setting up Counter-Processor!${RESET}"
/bin/cp -R /tmp/counter-processor-0.0.1 /usr/local/counter-processor
cp $DIR/bin/GeoLite2-Country /tmp/GeoLite2-Country.tar.gz
tar xvfz /tmp/GeoLite2-Country.tar.gz -C /tmp
cp /tmp/GeoLite2-Country_*/GeoLite2-Country.mmdb /usr/local/counter-processor/maxmind_geoip
# USER COUNTER
useradd counter
usermod -s /sbin/nologin counter
chown -R counter:counter /usr/local/counter-processor
echo "${GREEN}Installing Counter-Processor!${RESET}"
# INSTALL PIP3
sudo -S -u counter python3.6 -m ensurepip
# INSTALL DEPENDENCIES
sudo -S -u counter pip3 install --user -r /usr/local/counter-processor/requirements.txt
echo " "
echo "${GREEN}Counter-Processor installed!${RESET}"
echo "Stage (6/10) done!"
echo "${RED}Ctrl+C${RESET} to stop or ${GREEN}Enter${RESET} to continue!"
# read -e $X
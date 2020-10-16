#!/bin/bash
DIR=$PWD
RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`
echo "${GREEN}Stopping Solr!${RESET}"
sudo systemctl stop solr
echo "${GREEN}Installing dependencies!${RESET}"
sudo yum install -y lsof
echo "${GREEN}Backing up old installation!${RESET}"
TIMESTAMP=$(date "+%Y.%m.%d-%H.%M.%S")
/bin/cp -R /usr/local/solr $DIR/backup/solr-$TIMESTAMP
echo "${GREEN}Removing old settings!${RESET}"
sudo rm -rf /tmp/solr-7.7.2
# SOLR DEPENDENCIES
echo "${GREEN}Downloading Solr!${RESET}"
FILE="solr-7.7.2.tgz"
LOCATION="/tmp/$FILE"
LINK=https://archive.apache.org/dist/lucene/solr/7.7.2/solr-7.7.2.tgz
if [ -f "$LOCATION" ]; then
    ls $LOCATION
    if [ "$(md5sum $LOCATION)" == "00421a08940f110e8cf3bb0d67aea1a5  $LOCATION" ]; then
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
echo "${GREEN}Setting up Solr!${RESET}"
# INSTALLING SOLR
sudo mkdir /usr/local/solr
sudo /bin/cp -R /tmp/solr-7.7.2 /usr/local/solr
echo "${GREEN}Cleaning Solr collection!${RESET}"
sudo -u solr /usr/local/solr/solr-7.7.2/bin/solr delete -c collection1
sudo rm -rf /usr/local/solr/solr-7.7.2/server/solr/collection1
# SETTING SOLR
echo "${GREEN}Setting up Solr collection!${RESET}"
sudo /bin/cp -Rf /usr/local/solr/solr-7.7.2/server/solr/configsets/_default /usr/local/solr/solr-7.7.2/server/solr/collection1
sudo /bin/mv /usr/local/solr/solr-7.7.2/server/solr/collection1/conf/schema.xml /usr/local/solr/solr-7.7.2/server/solr/collection1/conf/schema.xml.bkp
sudo wget https://raw.githubusercontent.com/IQSS/dataverse/v4.20/conf/solr/7.7.2/schema.xml -P /usr/local/solr/solr-7.7.2/server/solr/collection1/conf
sudo wget https://raw.githubusercontent.com/IQSS/dataverse/v4.20/conf/solr/7.7.2/schema_dv_mdb_copies.xml -P /usr/local/solr/solr-7.7.2/server/solr/collection1/conf
sudo wget https://raw.githubusercontent.com/IQSS/dataverse/v4.20/conf/solr/7.7.2/schema_dv_mdb_fields.xml -P /usr/local/solr/solr-7.7.2/server/solr/collection1/conf
sudo /bin/mv /usr/local/solr/solr-7.7.2/server/solr/collection1/conf/solrconfig.xml /usr/local/solr/solr-7.7.2/server/solr/collection1/conf/solrconfig.xml.bkp
sudo wget https://raw.githubusercontent.com/IQSS/dataverse/v4.20/conf/solr/7.7.2/solrconfig.xml -P /usr/local/solr/solr-7.7.2/server/solr/collection1/conf
sudo echo "name=collection1" > /usr/local/solr/solr-7.7.2/server/solr/collection1/core.properties
# USER SOLR
sudo useradd solr
sudo usermod -s /sbin/nologin solr
sudo chown -R solr:solr /usr/local/solr
# KERNEL LIMITS
sudo /bin/cp -f /etc/security/limits.conf /etc/security/limits.conf.bkp
sudo /bin/cp -f $DIR/conf/limits.conf /etc/security/limits.conf
# SOLR SERVICE
sudo /bin/cp -f /usr/lib/systemd/system/solr.service /usr/lib/systemd/system/solr.service.bkp
sudo /bin/cp -f $DIR/service/solr.service /usr/lib/systemd/system/
sudo systemctl daemon-reload
# echo "SOLR_LOCATION	localhost:8983" >>$DIR/default.config
# echo "TWORAVENS_LOCATION	NOT INSTALLED" >>$DIR/default.config
# SOLR SYSTEM START
echo "${GREEN}Enabling Solr to start with the system!${RESET}"
sudo systemctl enable solr
echo "${GREEN}Starting Solr!${RESET}"
sudo systemctl start solr
sleep 4
# SOLR COLLECTION
echo "${GREEN}Creating collection!${RESET}"
sudo -u solr /usr/local/solr/solr-7.7.2/bin/solr create_core -c collection1 -d /usr/local/solr/solr-7.7.2/server/solr/collection1/conf/
echo "${GREEN}Restarting Solr!${RESET}"
sudo systemctl stop solr
sudo systemctl start solr
sleep 4
# SERVICE SOLR STATUS
echo "${GREEN}Solr status!${RESET}"
sudo systemctl status solr
echo " "
echo "${GREEN}Solr installed!${RESET}"
echo "Stage (3/13) done!"
echo "${RED}Ctrl+C${RESET} to stop or ${GREEN}Enter${RESET} to continue!"
read -e $X
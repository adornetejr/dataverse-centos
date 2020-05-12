#!/bin/bash
DIR=$PWD
RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`
echo "${GREEN}Stopping Solr!${RESET}"
systemctl stop solr
echo "${GREEN}Installing dependencies!${RESET}"
yum install -y lsof
echo "${GREEN}Removing old settings!${RESET}"
rm -rf /tmp/solr-7.3.1
TIMESTAMP=$(date "+%Y.%m.%d-%H.%M.%S")
mv /usr/local/solr /usr/local/solr-$TIMESTAMP
# SOLR DEPENDENCIES
echo "${GREEN}Downloading Solr!${RESET}"
FILE="solr-7.3.1.tgz"
LOCATION="/tmp/$FILE"
LINK=https://archive.apache.org/dist/lucene/solr/7.3.1/solr-7.3.1.tgz
if [ -f "$LOCATION" ]; then
    ls $LOCATION
    if [ "$(md5sum $LOCATION)" == "042a6c0d579375be1a8886428f13755f  $LOCATION" ]; then
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
mkdir /usr/local/solr
cp -R /tmp/solr-7.3.1 /usr/local/solr
sudo -u solr /usr/local/solr/solr-7.3.1/bin/solr delete -c collection1
rm -rf /usr/local/solr/solr-7.3.1/server/solr/collection1
# SETTING SOLR
cp -R /usr/local/solr/solr-7.3.1/server/solr/configsets/_default /usr/local/solr/solr-7.3.1/server/solr/collection1
mv /usr/local/solr/solr-7.3.1/server/solr/collection1/conf/schema.xml /usr/local/solr/solr-7.3.1/server/solr/collection1/conf/schema.xml.bkp
wget https://raw.githubusercontent.com/IQSS/dataverse/v4.19/conf/solr/7.3.1/schema.xml -P /usr/local/solr/solr-7.3.1/server/solr/collection1/conf
wget https://raw.githubusercontent.com/IQSS/dataverse/v4.19/conf/solr/7.3.1/schema_dv_mdb_copies.xml -P /usr/local/solr/solr-7.3.1/server/solr/collection1/conf
wget https://raw.githubusercontent.com/IQSS/dataverse/v4.19/conf/solr/7.3.1/schema_dv_mdb_fields.xml -P /usr/local/solr/solr-7.3.1/server/solr/collection1/conf
mv /usr/local/solr/solr-7.3.1/server/solr/collection1/conf/solrconfig.xml /usr/local/solr/solr-7.3.1/server/solr/collection1/conf/solrconfig.xml.bkp
wget https://raw.githubusercontent.com/IQSS/dataverse/v4.19/conf/solr/7.3.1/solrconfig.xml -P /usr/local/solr/solr-7.3.1/server/solr/collection1/conf
# USER SOLR
useradd solr
usermod -s /sbin/nologin solr
chown -R solr:solr /usr/local/solr
# KERNEL LIMITS
mv /etc/security/limits.conf /etc/security/limits.conf.bkp
cp $DIR/conf/limits.conf /etc/security/limits.conf
# SOLR SERVICE
mv /usr/lib/systemd/system/solr.service /usr/lib/systemd/system/solr.service.bkp
cp $DIR/service/solr.service /usr/lib/systemd/system/
systemctl daemon-reload
echo "SOLR_LOCATION	localhost:8983" >>$DIR/default.config
echo "TWORAVENS_LOCATION	NOT INSTALLED" >>$DIR/default.config
# SOLR SYSTEM START
echo "${GREEN}Enabling Solr to start with the system!${RESET}"
systemctl enable solr
echo "${GREEN}Starting Solr!${RESET}"
systemctl start solr
# SOLR COLLECTION
echo "${GREEN}Creating collection!${RESET}"
sudo -u solr /usr/local/solr/solr-7.3.1/bin/solr create_core -c collection1 -d /usr/local/solr/solr-7.3.1/server/solr/collection1/conf/
echo "${GREEN}Restarting Solr!${RESET}"
systemctl stop solr
systemctl start solr
# SERVICE SOLR STATUS
systemctl status solr
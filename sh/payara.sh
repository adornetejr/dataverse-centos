#!/bin/bash
DIR=$PWD
RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`
echo "${GREEN}Stopping Payara!${RESET}"
sudo systemctl stop payara
# GLASSFISH DEPENDENCIES
echo "${GREEN}Installing dependencies!${RESET}"
sudo yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel jq ImageMagick
echo "${GREEN}Backing up old installation!${RESET}"
TIMESTAMP=$(date "+%Y.%m.%d-%H.%M.%S")
sudo /bin/cp -R /usr/local/payara5 $DIR/backup/payara5-$TIMESTAMP
echo "${GREEN}Removing old settings!${RESET}"
sudo rm -rf /tmp/payara5
echo "${GREEN}Downloading Payara!${RESET}"
FILE="payara-5.2020.2.zip"
LOCATION="/tmp/$FILE"
LINK=https://github.com/payara/Payara/releases/download/payara-server-5.2020.2/payara-5.2020.2.zip
if [ -f "$LOCATION" ]; then
    ls $LOCATION
    if [ "$(md5sum $LOCATION)" == "98b42b1313be4252403c9ca0d8f7e776  $LOCATION" ]; then
        sudo unzip /tmp/$FILE -d /tmp
    else
        sudo rm -rf $LOCATION
        sudo wget $LINK -P /tmp
        sudo unzip /tmp/$FILE -d /tmp
    fi
else
    sudo wget $LINK -P /tmp
    sudo unzip /tmp/$FILE -d /tmp
fi
echo "${GREEN}Setting up Payara!${RESET}"
sudo /bin/cp -R /tmp/payara5 /usr/local/
# FIX MODULE WELD-OSGI
# echo "${GREEN}Updating Weld-OSGi Module!${RESET}"
# sudo /bin/mv /usr/local/glassfish4/glassfish/modules/weld-osgi-bundle.jar /usr/local/glassfish4/glassfish/modules/weld-osgi-bundle.jar.bkp
# sudo curl -L -o /usr/local/glassfish4/glassfish/modules/weld-osgi-bundle.jar https://search.maven.org/remotecontent?filepath=org/jboss/weld/weld-osgi-bundle/2.2.10.Final/weld-osgi-bundle-2.2.10.Final-glassfish4.jar
# echo " "
# wget http://central.maven.org/maven2/org/jboss/weld/weld-osgi-bundle/2.2.10.SP1/weld-osgi-bundle-2.2.10.SP1-glassfish4.jar
# SETTING GLASSFISH
sudo /bin/mv /usr/local/payara5/glassfish/domains/domain1/config/domain.xml /usr/local/payara5/glassfish/domains/domain1/config/domain.xml.bkp
sudo /bin/cp -f $DIR/xml/domain.xml /usr/local/payara5/glassfish/domains/domain1/config/domain.xml
# GLASSFISH SSL CERTIFICATE
echo "${GREEN}Updating SSL Certificates!${RESET}"
sudo update-ca-trust
sudo /bin/mv /usr/local/payara5/glassfish/domains/domain1/config/cacerts.jks /usr/local/payara5/glassfish/domains/domain1/config/cacerts.jks.bkp
sudo /bin/cp -f /etc/pki/java/cacerts /usr/local/payara5/glassfish/domains/domain1/config/cacerts.jks
# USER GLASSFISH
sudo useradd payara
sudo usermod -s /sbin/nologin payara
sudo chown -R root:root /usr/local/payara5
sudo chown -R payara:payara /usr/local/payara5/glassfish/lib
sudo chown -R payara:payara /usr/local/payara5/glassfish/domains/domain1
# GLASSFISH SERVICE
sudo /bin/cp -f /usr/lib/systemd/system/payara.service /usr/lib/systemd/system/payara.service.bkp
sudo /bin/cp -f $DIR/service/payara.service /usr/lib/systemd/system/payara.service
sudo systemctl daemon-reload
echo "GLASSFISH_USER    glassfish" >>$DIR/default.config
echo "GLASSFISH_DIRECTORY	/usr/local/payara5" >>$DIR/default.config
# GLASSFISH SYSTEM START
echo "${GREEN}Enabling Payara to start with the system!${RESET}"
sudo systemctl enable payara.service
echo "${GREEN}Starting Payara!${RESET}"
sudo systemctl start payara.service
sleep 10
# SERVICE GLASSFISH
echo "${GREEN}Payara status!${RESET}"
sudo systemctl status payara.service
echo " "
echo "${GREEN}Payara installed!${RESET}"
echo "Stage (2/13) done!"
echo "${RED}Ctrl+C${RESET} to stop or ${GREEN}Enter${RESET} to continue!"
read -e $X

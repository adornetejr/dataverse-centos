#!/bin/bash
DIR=$PWD
RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`
echo "${GREEN}Stopping Glassfish!${RESET}"
sudo systemctl stop glassfish
# GLASSFISH DEPENDENCIES
echo "${GREEN}Installing dependencies!${RESET}"
sudo yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel jq ImageMagick
echo "${GREEN}Backing up old installation!${RESET}"
TIMESTAMP=$(date "+%Y.%m.%d-%H.%M.%S")
sudo /bin/cp -R /usr/local/glassfish4 $DIR/backup/glassfish4-$TIMESTAMP
echo "${GREEN}Removing old settings!${RESET}"
sudo rm -rf /tmp/glassfish4
echo "${GREEN}Downloading Glassfish!${RESET}"
FILE="glassfish-4.1.zip"
LOCATION="/tmp/$FILE"
LINK=https://dlc-cdn.sun.com/glassfish/4.1/release/glassfish-4.1.zip
if [ -f "$LOCATION" ]; then
    ls $LOCATION
    if [ "$(md5sum $LOCATION)" == "2fd41ad9af8d41d1c721c1b25191f674  $LOCATION" ]; then
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
echo "${GREEN}Setting up Glassfish!${RESET}"
sudo /bin/cp -R /tmp/glassfish4 /usr/local/
# FIX MODULE WELD-OSGI
echo "${GREEN}Updating Weld-OSGi Module!${RESET}"
sudo /bin/mv /usr/local/glassfish4/glassfish/modules/weld-osgi-bundle.jar /usr/local/glassfish4/glassfish/modules/weld-osgi-bundle.jar.bkp
sudo curl -L -o /usr/local/glassfish4/glassfish/modules/weld-osgi-bundle.jar https://search.maven.org/remotecontent?filepath=org/jboss/weld/weld-osgi-bundle/2.2.10.Final/weld-osgi-bundle-2.2.10.Final-glassfish4.jar
echo " "
# wget http://central.maven.org/maven2/org/jboss/weld/weld-osgi-bundle/2.2.10.SP1/weld-osgi-bundle-2.2.10.SP1-glassfish4.jar
# SETTING GLASSFISH
sudo /bin/mv /usr/local/glassfish4/glassfish/domains/domain1/config/domain.xml /usr/local/glassfish4/glassfish/domains/domain1/config/domain.xml.bkp
sudo /bin/cp -f $DIR/xml/domain.xml /usr/local/glassfish4/glassfish/domains/domain1/config/domain.xml
# GLASSFISH SSL CERTIFICATE
echo "${GREEN}Updating SSL Certificates!${RESET}"
sudo update-ca-trust
sudo /bin/mv /usr/local/glassfish4/glassfish/domains/domain1/config/cacerts.jks /usr/local/glassfish4/glassfish/domains/domain1/config/cacerts.jks.bkp
sudo /bin/cp -f /etc/pki/java/cacerts /usr/local/glassfish4/glassfish/domains/domain1/config/cacerts.jks
# USER GLASSFISH
sudo useradd glassfish
sudo usermod -s /sbin/nologin glassfish
sudo chown -R root:root /usr/local/glassfish4
sudo chown -R glassfish:glassfish /usr/local/glassfish4/glassfish/lib
sudo chown -R glassfish:glassfish /usr/local/glassfish4/glassfish/domains/domain1
# GLASSFISH SERVICE
sudo /bin/cp -f /usr/lib/systemd/system/glassfish.service /usr/lib/systemd/system/glassfish.service.bkp
sudo /bin/cp -f $DIR/service/glassfish.service /usr/lib/systemd/system/glassfish.service
sudo systemctl daemon-reload
echo "GLASSFISH_USER    glassfish" >>$DIR/default.config
echo "GLASSFISH_DIRECTORY	/usr/local/glassfish4" >>$DIR/default.config
# GLASSFISH SYSTEM START
echo "${GREEN}Enabling Glassfish to start with the system!${RESET}"
sudo systemctl enable glassfish
echo "${GREEN}Starting Glassfish!${RESET}"
sudo systemctl start glassfish
sleep 10
# SERVICE GLASSFISH
echo "${GREEN}Glassfish status!${RESET}"
sudo systemctl status glassfish
echo " "
echo "${GREEN}Glassfish installed!${RESET}"
echo "Stage (2/13) done!"
echo "${RED}Ctrl+C${RESET} to stop or ${GREEN}Enter${RESET} to continue!"
read -e $X

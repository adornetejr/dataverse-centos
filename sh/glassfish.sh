#!/bin/bash
DIR=$PWD
RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`
echo "${GREEN}Stopping Glassfish!${RESET}"
systemctl stop glassfish
# GLASSFISH DEPENDENCIES
echo "${GREEN}Installing dependencies!${RESET}"
yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel jq ImageMagick
echo "${GREEN}Backing up old installation!${RESET}"
TIMESTAMP=$(date "+%Y.%m.%d-%H.%M.%S")
mv /usr/local/glassfish4 /usr/local/glassfish4-$TIMESTAMP
echo "/usr/local/glassfish4-$TIMESTAMP"
rm -rf /tmp/glassfish4
echo "${GREEN}Downloading Glassfish!${RESET}"
FILE="glassfish-4.1.zip"
LOCATION="/tmp/$FILE"
LINK=https://dlc-cdn.sun.com/glassfish/4.1/release/glassfish-4.1.zip
if [ -f "$LOCATION" ]; then
    ls $LOCATION
    if [ "$(md5sum $LOCATION)" == "2fd41ad9af8d41d1c721c1b25191f674  $LOCATION" ]; then
        unzip /tmp/$FILE -d /tmp
    else
        rm $LOCATION
        wget $LINK -P /tmp
        unzip /tmp/$FILE -d /tmp
    fi
else
    wget $LINK -P /tmp
    unzip /tmp/$FILE -d /tmp
fi
echo "${GREEN}Setting up Glassfish!${RESET}"
cp -R /tmp/glassfish4 /usr/local/
# FIX MODULE WELD-OSGI
echo "${GREEN}Updating Weld-OSGi Module!${RESET}"
mv /usr/local/glassfish4/glassfish/modules/weld-osgi-bundle.jar /usr/local/glassfish4/glassfish/modules/weld-osgi-bundle.jar.bkp
curl -L -o /usr/local/glassfish4/glassfish/modules/weld-osgi-bundle.jar https://search.maven.org/remotecontent?filepath=org/jboss/weld/weld-osgi-bundle/2.2.10.Final/weld-osgi-bundle-2.2.10.Final-glassfish4.jar
# wget http://central.maven.org/maven2/org/jboss/weld/weld-osgi-bundle/2.2.10.SP1/weld-osgi-bundle-2.2.10.SP1-glassfish4.jar
# SETTING GLASSFISH
mv /usr/local/glassfish4/glassfish/domains/domain1/config/domain.xml /usr/local/glassfish4/glassfish/domains/domain1/config/domain.xml.bkp
cp $DIR/xml/domain.xml /usr/local/glassfish4/glassfish/domains/domain1/config/domain.xml
# GLASSFISH SSL CERTIFICATE
echo "${GREEN}Updating SSL Certificates!${RESET}"
mv /usr/local/glassfish4/glassfish/domains/domain1/config/cacerts.jks /usr/local/glassfish4/glassfish/domains/domain1/config/cacerts.jks.bkp
cp -f /usr/lib/jvm/java-1.8.0-openjdk/jre/lib/security/cacerts /usr/local/glassfish4/glassfish/domains/domain1/config/cacerts.jks
# USER GLASSFISH
useradd glassfish
usermod -s /sbin/nologin glassfish
chown -R root:root /usr/local/glassfish4
chown -R glassfish:glassfish /usr/local/glassfish4/glassfish/lib
chown -R glassfish:glassfish /usr/local/glassfish4/glassfish/domains/domain1
# GLASSFISH SERVICE
mv /usr/lib/systemd/system/glassfish.service /usr/lib/systemd/system/glassfish.service.bkp
cp $DIR/service/glassfish.service /usr/lib/systemd/system/glassfish.service
systemctl daemon-reload
echo "GLASSFISH_USER    glassfish" >>$DIR/default.config
echo "GLASSFISH_DIRECTORY	/usr/local/glassfish4" >>$DIR/default.config
# GLASSFISH SYSTEM START
echo "${GREEN}Enabling Glassfish to start with the system!${RESET}"
systemctl enable glassfish
echo "${GREEN}Starting Glassfish!${RESET}"
systemctl start glassfish
# SERVICE GLASSFISH
echo "${GREEN}Glassfish status!${RESET}"
systemctl status glassfish
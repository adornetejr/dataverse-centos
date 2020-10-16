clear
DIR=$PWD
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)
echo "${GREEN}Removing old settings!${RESET}"
rm -rf /tmp/dvinstall
# DOWNLOAD DATAVERSE
echo "${GREEN}Downloading Dataverse!${RESET}"
FILE="dvinstall.zip"
LOCATION="/tmp/$FILE"
LINK=https://github.com/IQSS/dataverse/releases/download/v5.1.1/dvinstall.zip
if [ -f "$LOCATION" ]; then
    ls $LOCATION
    if [ "$(md5sum $LOCATION)" == "e829887b090aace51d1f3d96a9254038  $LOCATION" ]; then
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
sudo /bin/cp /tmp/dvinstall/default.config /tmp/dvinstall/default.config.bkp
# /bin/cp -f $DIR/default.config /tmp/dvinstall/default.config
clear
echo "${GREEN}Dataverse Install Settings:${RESET}"
echo " "
DEF="POSTGRES_SERVER = localhost"
PASS="POSTGRES_SERVER = 127.0.0.1"
sudo sed -i "s/$DEF/$PASS/g" /tmp/dvinstall/default.config
DEF="POSTGRES_ADMIN_PASSWORD = secret"
PASS="POSTGRES_ADMIN_PASSWORD = $(cat $DIR/root.pass)"
sudo sed -i "s/$DEF/$PASS/g" /tmp/dvinstall/default.config
DEF="POSTGRES_PASSWORD = secret"
PASS="POSTGRES_PASSWORD = $(cat $DIR/user.pass)"
sudo sed -i "s/$DEF/$PASS/g" /tmp/dvinstall/default.config
DEF="MAIL_SERVER = localhost"
PASS="MAIL_SERVER = $(cat $DIR/hostname)"
sudo sed -i "s/$DEF/$PASS/g" /tmp/dvinstall/default.config
DEF="POSTGRES_SERVER = localhost"
PASS="POSTGRES_SERVER = 127.0.0.1"
sudo sed -i "s/$DEF/$PASS/g" /tmp/dvinstall/default.config
cat /tmp/dvinstall/default.config
echo " "
echo "${RED}Attention!${RESET}"
echo " "
echo "If the next step freeze in 'Updates Done. Retarting...'"
echo " "
echo "Open another terminal and run the command:"
echo "# sudo systemctl restart payara.service"
echo " "
echo "${RED}Ctrl+C${RESET} to stop or ${GREEN}Enter${RESET} to continue!"
read -e $X
# START INSTALLER
cd /tmp/dvinstall/
echo " "
echo "${GREEN}Wait... Deploying.${RESET}"
/bin/cp -f /usr/local/payara5/glassfish/domains/domain1/logs/server.log $DIR/logs/payara.log
sudo -u dataverse ./install
/bin/cp -f /usr/local/payara5/glassfish/domains/domain1/logs/server.log $DIR/logs/dataverse.log
# ./install -y -f > $DIR/logs/install.log 2> $DIR/logs/install.err
# FIX "EJB Timer Service" ERROR ON DEPLOY
sudo /usr/local/payara5/bin/asadmin stop-domain
sudo rm -rf /usr/local/payara5/glassfish/domains/domain1/generated/
sudo rm -rf /usr/local/payara5/glassfish/domains/domain1/osgi-cache/felix
sudo -u postgres psql dvndb -c 'delete from "EJB__TIMER__TBL"';
echo "Installer log file $DIR/logs/install.log"
echo "Installer error file $DIR/logs/install.err"
echo "Dataverse deploy log file $DIR/logs/dataverse.log"
# PAYARA PERMISSIONS
sudo chown -R dataverse:dataverse /usr/local/payara5
# sudo chown -R root:root /usr/local/payara5
# sudo chown -R dataverse:dataverse /usr/local/payara5/glassfish/lib
# sudo chown -R dataverse:dataverse /usr/local/payara5/glassfish/domains/domain1
# RESTARTING PAYARA
echo "${GREEN}Restarting Payara!${RESET}"
sudo systemctl restart payara.service
sleep 10
# SERVICE PAYARA STATUS
echo "${GREEN}Payara status!${RESET}"
sudo systemctl status payara.service
echo " "
echo "${GREEN}Payara deployed applications:${RESET}"
sudo /usr/local/payara5/bin/asadmin list-applications
echo " "
echo "${GREEN}Dataverse deployed!${RESET}"
echo "Stage (7/13) done!"
echo "${RED}Ctrl+C${RESET} to stop or ${GREEN}Enter${RESET} to continue!"
read -e $X
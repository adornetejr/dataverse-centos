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
LINK=https://github.com/IQSS/dataverse/releases/download/v4.19/dvinstall.zip
if [ -f "$LOCATION" ]; then
    ls $LOCATION
    if [ "$(md5sum $LOCATION)" == "de4f375f0c68c404e8adc52092cb8334  $LOCATION" ]; then
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
mv /tmp/dvinstall/default.config /tmp/dvinstall/default.config.bkp
cp $DIR/default.config /tmp/dvinstall/default.config
clear
echo "${GREEN}Dataverse Install Settings:${RESET}"
echo " "
cat /tmp/dvinstall/default.config
echo " "
echo "${RED}Attention!${RESET}"
echo " "
echo "If the next step freeze in 'Updates Done. Retarting...'"
echo " "
echo "Open another terminal and run the command:"
echo "# systemctl restart glassfish"
echo " "
echo "${RED}Ctrl+C${RESET} to stop or ${GREEN}Enter${RESET} to continue!"
read -e $X
# START INSTALLER
cd /tmp/dvinstall/
echo " "
echo "${GREEN}Wait... Deploying.${RESET}"
sudo -S -u glassfish ./install -y -f > $DIR/logs/install.log 2> $DIR/logs/install.err
# ./install -y -f > $DIR/logs/install.log 2> $DIR/logs/install.err
echo "Installer log file $DIR/logs/install.log"
echo "Installer error file $DIR/logs/install.err"
# SETTING UP POSTGRES ACCESS
echo "${GREEN}Restart Postgres!${RESET}"
systemctl stop postgresql-9.6
mv /var/lib/pgsql/9.6/data/pg_hba.conf /var/lib/pgsql/9.6/data/pg_hba.conf.2.bkp
cp $DIR/conf/pg_hba_md5.conf /var/lib/pgsql/9.6/data/pg_hba.conf
systemctl start postgresql-9.6
# RESTARTING GLASSFISH
echo "${GREEN}Restarting Glassfish!${RESET}"
systemctl stop glassfish
# chown -R glassfish:glassfish /usr/local/glassfish4
chown -R root:root /usr/local/glassfish4
chown -R glassfish:glassfish /usr/local/glassfish4/glassfish/lib
chown -R glassfish:glassfish /usr/local/glassfish4/glassfish/domains/domain1
systemctl restart glassfish
# SERVICE GLASSFISH STATUS
echo "${GREEN}Glassfish status!${RESET}"
systemctl status glassfish
echo " "
echo "${GREEN}Glassfish deployed applications:${RESET}"
/usr/local/glassfish4/bin/asadmin list-applications
echo " "
echo "${GREEN}Dataverse deployed!${RESET}"
echo "Stage (7/10) done!"
echo "${RED}Ctrl+C${RESET} to stop or ${GREEN}Enter${RESET} to continue!"
read -e $X
clear
DIR=$PWD
# DOWNLOAD DATAVERSE
echo "Downloading Dataverse!"
FILE="dvinstall.zip"
LOCATION="/tmp/$FILE"
LINK=https://github.com/IQSS/dataverse/releases/download/v4.19/dvinstall.zip
rm -rf /tmp/dvinstall
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
clear
echo "Attention!!"
echo " "
echo "If the next step freeze in 'Updates Done. Retarting...'"
echo " "
echo "Open another terminal and run the command:"
echo "# systemctl restart glassfish"
echo " "
echo "Ctrl+C to cancel or Enter to continue!"
read -e $X
mv /tmp/dvinstall/default.config /tmp/dvinstall/default.config.bkp
cp $DIR/default.config /tmp/dvinstall/default.config
clear
echo "Dataverse Install Settings:"
echo " "
cat /tmp/dvinstall/default.config
echo " "
echo "Ctrl+C to cancel or Enter to continue!"
read -e $X
# START INSTALLER
cd /tmp/dvinstall/
echo " "
echo "Wait... Installing."
sudo -S -u glassfish ./install -y -f > $DIR/logs/install.out 2> $DIR/logs/install.err
echo "Installer log file $DIR/logs/install.out"
echo "Installer error file $DIR/logs/install.err"
# SETTING UP POSTGRES ACCESS
echo "Restart Postgresql"
systemctl stop postgresql-9.6
rm -rf /var/lib/pgsql/9.6/data/pg_hba.conf
cp $DIR/conf/pg_hba_md5.conf /var/lib/pgsql/9.6/data/pg_hba.conf
systemctl start postgresql-9.6
# SECURE GLASSFISH
/usr/local/glassfish4/glassfish/bin/asadmin change-admin-password
/usr/local/glassfish4/glassfish/bin/asadmin --host localhost --port 4848 enable-secure-admin
# RESTARTING GLASSFISH
echo "Restarting Glassfish!"
systemctl stop glassfish
systemctl start glassfish
# SERVICE GLASSFISH STATUS
systemctl status glassfish
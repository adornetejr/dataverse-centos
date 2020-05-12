clear
DIR=$PWD
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
sudo -S -u glassfish ./install -y -f > $DIR/install.out 2> $DIR/install.err
echo "Install log file $DIR/install.out"
# SETTING UP POSTGRES ACCESS
systemctl stop postgresql-9.6
rm -rf /var/lib/pgsql/9.6/data/pg_hba.conf
cp $DIR/conf/pg_hba_md5.conf /var/lib/pgsql/9.6/data/pg_hba.conf
systemctl start postgresql-9.6
# RESTARTING GLASSFISH
systemctl stop glassfish
systemctl start glassfish
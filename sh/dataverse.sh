clear
DIR=$PWD
echo "ATENÇÃO!!"
echo " "
echo "Se a próxima etapa trancar em 'Updates Done. Retarting...' por mais de 30 segundos."
echo " "
echo "Abra outro terminal e execute o comando:"
echo "# systemctl restart glassfish"
echo " "
echo "Pressione Ctrl+C para cancelar e Enter para continuar!"
read -e $X
mv /tmp/dvinstall/default.config /tmp/dvinstall/default.config.bkp
cp $DIR/default.config /tmp/dvinstall/default.config
clear
cat /tmp/dvinstall/default.config
# START INSTALLER
cd /tmp/dvinstall/
sudo -S -u glassfish ./install -y -f > install.out 2> install.err
# SETTING UP POSTGRES ACCESS
systemctl stop postgresql-9.6
rm -rf /var/lib/pgsql/9.6/data/pg_hba.conf
cp $DIR/conf/pg_hba_md5.conf /var/lib/pgsql/9.6/data/pg_hba.conf
rm -rf $DIR/default.config /tmp/dvinstall/default.config
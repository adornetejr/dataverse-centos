#!/bin/bash
DIR=$PWD
echo "Stopping Postgresql"
systemctl stop postgresql-9.6
echo "Removing old settings!"
yum remove -y postgresql96-server
yum autoremove -y
TIMESTAMP=$(date "+%Y.%m.%d-%H.%M.%S")
mv /var/lib/pgsql /var/lib/pgsql-$TIMESTAMP
mv /usr/pgsql-9.6 /usr/pgsql-9.6-$TIMESTAMP
#  POSTGRES REPOSITORY
echo "Installing Postgresql!"
yum install -y https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7.1-x86_64/pgdg-redhat-repo-latest.noarch.rpm
yum makecache fast
yum install -y postgresql96-server
# STARTING DATABASE
/usr/pgsql-9.6/bin/postgresql96-setup initdb
echo "Starting Postgresql!"
systemctl start postgresql-9.6
systemctl stop postgresql-9.6
# SETTING UP POSTGRES ACCESS
mv /var/lib/pgsql/9.6/data/pg_hba.conf /var/lib/pgsql/9.6/data/pg_hba.conf.bkp
cp $DIR/conf/pg_hba_trust.conf /var/lib/pgsql/9.6/data/pg_hba.conf
# CHANGE ROOT PASSWORD
echo "Alterando senha usuário root do postgres"
read -ep "Password: " PASSWORD
systemctl start postgresql-9.6
psql -U postgres -c "alter user postgres with password '$PASSWORD';"
echo "POSTGRES_ADMIN_PASSWORD	$PASSWORD" >>$DIR/default.config
echo "POSTGRES_SERVER	127.0.0.1" >>$DIR/default.config
echo "POSTGRES_PORT	5432" >>$DIR/default.config
echo "POSTGRES_DATABASE	dvndb" >>$DIR/default.config
echo "POSTGRES_USER	dvnapp" >>$DIR/default.config
echo "Crie senha usuário dvndb do postgres"
read -p "Password: " PASSWORD
echo "POSTGRES_PASSWORD	CREATE_DVNAPP_PASSWORD" >>$DIR/default.config
# POSTGRES SYSTEM START
echo "Enabling Postgresql to start with the system!"
systemctl enable postgresql-9.6
echo "Starting Postgresql!"
systemctl start postgresql-9.6
# SERVICE POSTGRES SERVICE
systemctl status postgresql-9.6
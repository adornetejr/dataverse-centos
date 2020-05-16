#!/bin/bash
DIR=$PWD
RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`
echo "${GREEN}Stopping Postgres!${RESET}"
systemctl stop postgresql-9.6
echo "${GREEN}Backing up old installation!${RESET}"
TIMESTAMP=$(date "+%Y.%m.%d-%H.%M.%S")
mv /var/lib/pgsql $DIR/backup/pgsql-$TIMESTAMP
/bin/cp -R /usr/pgsql-9.6 $DIR/backup/pgsql-9.6-$TIMESTAMP
yum remove -y postgresql96 postgresql96-server postgresql96-libs
#  POSTGRES REPOSITORY
echo "${GREEN}Installing dependencies!${RESET}"
yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
yum makecache fast
yum install -y postgresql96 postgresql96-server postgresql96-libs
# STARTING DATABASE
/usr/pgsql-9.6/bin/postgresql96-setup initdb
echo "${GREEN}Starting Postgres!${RESET}"
systemctl start postgresql-9.6
systemctl stop postgresql-9.6
# SETTING UP POSTGRES ACCESS
mv /var/lib/pgsql/9.6/data/pg_hba.conf /var/lib/pgsql/9.6/data/pg_hba.conf.bkp
cp $DIR/conf/pg_hba_trust.conf /var/lib/pgsql/9.6/data/pg_hba.conf
# CHANGE ROOT PASSWORD
until [[ ! -z "$PASSWORD" ]]; do
  clear
  echo "${GREEN}Change postgres password!${RESET}"
  read -ep "New root password: " PASSWORD
done
systemctl start postgresql-9.6
psql -U postgres -c "alter user postgres with password '$PASSWORD';"
echo "POSTGRES_ADMIN_PASSWORD	$PASSWORD" >>$DIR/default.config
echo "POSTGRES_SERVER	127.0.0.1" >>$DIR/default.config
echo "POSTGRES_PORT	5432" >>$DIR/default.config
echo "POSTGRES_DATABASE	dvndb" >>$DIR/default.config
echo "POSTGRES_USER	dvnapp" >>$DIR/default.config
until [[ ! -z "$USERPASS" ]]; do
  clear
  echo "${GREEN}Create dvndb password!${RESET}"
  read -ep "New user password: " USERPASS
done
echo "POSTGRES_PASSWORD	$USERPASS" >>$DIR/default.config
# POSTGRES SYSTEM START
echo "${GREEN}Enabling Postgres to start with the system!${RESET}"
systemctl enable postgresql-9.6
echo "${GREEN}Starting Postgres!${RESET}"
systemctl start postgresql-9.6
# SERVICE POSTGRES SERVICE
echo "${GREEN}Postgres status!${RESET}"
systemctl status postgresql-9.6
echo " "
echo "${GREEN}Postgres installed!${RESET}"
echo "Stage (4/10) done!"
echo "${RED}Ctrl+C${RESET} to stop or ${GREEN}Enter${RESET} to continue!"
# read -e $X
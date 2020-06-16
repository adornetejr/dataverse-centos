#!/bin/bash
DIR=$PWD
RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`
echo "${GREEN}Stopping Postgres!${RESET}"
sudo systemctl stop postgresql-9.6
echo "${GREEN}Backing up old installation!${RESET}"
TIMESTAMP=$(date "+%Y.%m.%d-%H.%M.%S")
/bin/cp -R /var/lib/pgsql $DIR/backup/pgsql-$TIMESTAMP
/bin/cp -R /usr/pgsql-9.6 $DIR/backup/pgsql-9.6-$TIMESTAMP
echo "${GREEN}Removing old settings!${RESET}"
yum remove -y postgresql96 postgresql96-server postgresql96-libs
rm -rf /var/lib/pgsql
#  POSTGRES REPOSITORY
echo "${GREEN}Installing dependencies!${RESET}"
yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
yum makecache fast
yum install -y postgresql96 postgresql96-server postgresql96-libs
# STARTING DATABASE
/usr/pgsql-9.6/bin/postgresql96-setup initdb
# SETTING UP POSTGRES ACCESS
/bin/cp -f /var/lib/pgsql/9.6/data/pg_hba.conf /var/lib/pgsql/9.6/data/pg_hba.conf.bkp
/bin/cp -f $DIR/conf/pg_hba_trust.conf /var/lib/pgsql/9.6/data/pg_hba.conf
echo " "
# CHANGE ROOT PASSWORD
until [[ ! -z "$PASSWORD" ]]; do
  echo "${GREEN}Change postgres password!${RESET}"
  read -ep "New root password: " PASSWORD
done
echo "${GREEN}Starting Postgres!${RESET}"
sudo systemctl start postgresql-9.6
sleep 4
psql -U postgres -c "alter user postgres with password '$PASSWORD';"
echo "POSTGRES_ADMIN_PASSWORD	$PASSWORD" >>$DIR/default.config
echo "POSTGRES_SERVER	127.0.0.1" >>$DIR/default.config
echo "POSTGRES_PORT	5432" >>$DIR/default.config
echo "POSTGRES_DATABASE	dvndb" >>$DIR/default.config
echo "POSTGRES_USER	dvnapp" >>$DIR/default.config
echo " "
until [[ ! -z "$USERPASS" ]]; do
  echo "${GREEN}Create dvndb password!${RESET}"
  read -ep "New user password: " USERPASS
done
echo "POSTGRES_PASSWORD	$USERPASS" >>$DIR/default.config
# POSTGRES SYSTEM START
echo "${GREEN}Enabling Postgres to start with the system!${RESET}"
sudo systemctl enable postgresql-9.6
echo "${GREEN}Starting Postgres!${RESET}"
sudo systemctl start postgresql-9.6
sleep 2
# SERVICE POSTGRES SERVICE
echo "${GREEN}Postgres status!${RESET}"
sudo systemctl status postgresql-9.6
echo " "
echo "${GREEN}Postgres installed!${RESET}"
echo "Stage (6/13) done!"
echo "${RED}Ctrl+C${RESET} to stop or ${GREEN}Enter${RESET} to continue!"
read -e $X
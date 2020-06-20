#!/bin/bash
DIR=$PWD
RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`
# INSTALL FIREWALLD
echo "${GREEN}Installing dependencies!${RESET}"
sudo yum install firewalld nmap
sudo systemctl start firewalld
sleep 2
# SSHD
# echo "${GREEN}Opening up port 22 for sshd!${RESET}"
# sudo firewall-cmd --permanent --add-port=22/tcp
# echo "${GREEN}Opening up port 2022 for sshd!${RESET}"
# sudo firewall-cmd --permanent --add-port=2022/tcp
# SENDMAIL
# echo "${GREEN}Opening up port 25 for Sendmail!${RESET}"
# sudo firewall-cmd --permanent --add-port=25/tcp
# NTPD
# echo "${GREEN}Opening up port 123 for ntpd!${RESET}"
# sudo firewall-cmd --permanent --add-port=123/tcp
# GLASSFISH HTTP
# echo "${GREEN}Opening up port 8080 for Glassfish!${RESET}"
# sudo firewall-cmd --permanent --add-port=8080/tcp
# GLASSFISH HTTPS
# echo "${GREEN}Opening up port 8181 for Glassfish!${RESET}"
# sudo firewall-cmd --permanent --add-port=8181/tcp
# GLASSFISH ADMIN
# echo "${GREEN}Opening up port 4848 for Glassfish Admin!${RESET}"
# sudo firewall-cmd --permanent --add-port=4848/tcp
# SOLR
# echo "${GREEN}Opening up port 8983 for Solr Indexing!${RESET}"
# sudo firewall-cmd --permanent --add-port=8983/tcp
# RSERVE
# echo "${GREEN}Opening up port 6311 for Rserve!${RESET}"
# sudo firewall-cmd --permanent --add-port=6311/tcp
# AJP CONNECTOR
# echo "${GREEN}Opening up port 8009 for Apache Jserve Proxy!${RESET}"
# sudo firewall-cmd --permanent --add-port=8009/tcp
# APACHE PROXY HTTP
echo "${GREEN}Opening up port 80 for Apache HTTP Proxy!${RESET}"
sudo firewall-cmd --permanent --add-port=80/tcp
# APACHE PROXY HTTPS
echo "${GREEN}Opening up port 443 for Apache HTTPs Proxy!${RESET}"
sudo firewall-cmd --permanent --add-port=443/tcp
# RELOAD CONFIG
echo "${GREEN}Firewalld reload configurations!${RESET}"
sudo firewall-cmd --reload
echo "${GREEN}Firewalld configuration:${RESET}"
sudo firewall-cmd --list-all
sleep 10
# sudo firewall-cmd --remove-port=22/tcp
# sudo firewall-cmd --remove-port=25/tcp
# sudo firewall-cmd --remove-port=123/tcp
# sudo firewall-cmd --remove-port=4848/tcp
# sudo firewall-cmd --remove-port=6311/tcp
# sudo firewall-cmd --remove-port=8009/tcp
# sudo firewall-cmd --remove-port=8080/tcp
# sudo firewall-cmd --remove-port=8181/tcp
# sudo firewall-cmd --remove-port=8983/tcp
# sudo firewall-cmd --runtime-to-permanent
# SETTING UP POSTGRES ACCESS
echo "${GREEN}Securing Postgres!${RESET}"
sudo systemctl stop postgresql-9.6
/bin/cp -f /var/lib/pgsql/9.6/data/pg_hba.conf /var/lib/pgsql/9.6/data/pg_hba.conf.2.bkp
/bin/cp -f $DIR/conf/pg_hba_md5.conf /var/lib/pgsql/9.6/data/pg_hba.conf
echo "${GREEN}Restarting Postgres!${RESET}"
sudo systemctl start postgresql-9.6
sleep 2
# SECURE GLASSFISH
echo "${GREEN}Securing Glassfish!${RESET}"
HOST=$(hostname --fqdn)
/usr/local/glassfish4/glassfish/bin/asadmin change-admin-password
/usr/local/glassfish4/glassfish/bin/asadmin --host localhost --port 4848 enable-secure-admin
/usr/local/glassfish4/glassfish/bin/asadmin --host $HOST --port 4848 enable-secure-admin
echo "${GREEN}Restarting Glassfish!${RESET}"
sudo systemctl restart glassfish
sleep 10
# SERVICE GLASSFISH STATUS
echo "${GREEN}Glassfish status!${RESET}"
sudo systemctl status glassfish
echo "${GREEN}Securing Apache!${RESET}"
sudo yum install -y mod_security
echo "${GREEN}Restarting Apache!${RESET}"
sudo systemctl restart httpd
# SERVICE GLASSFISH STATUS
echo "${GREEN}Apache status!${RESET}"
sudo systemctl status httpd
# FIREWALLD SYSTEM START
echo "${GREEN}Enabling Firewalld to start with the system!${RESET}"
sudo systemctl enable firewalld
echo "${GREEN}Restarting Firewalld!${RESET}"
sudo systemctl restart firewalld
# FIREWALLD STATUS
echo "${GREEN}Firewalld status!${RESET}"
sudo systemctl status firewalld
echo " "
echo "${GREEN}Checking open ports!${RESET}"
nmap -v $HOST
echo "${GREEN}Firewalld installed!${RESET}"
echo "Stage (13/13) done!"
echo "${RED}Ctrl+C${RESET} to stop or ${GREEN}Enter${RESET} to continue!"
read -e $X
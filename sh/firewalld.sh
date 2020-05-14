#!/bin/bash
RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`
# SERVICE FIREWALLD RESTART
systemctl enable firewalld
systemctl start firewalld
# FIREWALLD PORTS
# SENDMAIL
firewall-cmd --permanent --add-port=25/tcp
# GLASSFISH HTTP
firewall-cmd --permanent --add-port=8080/tcp
# GLASSFISH HTTPS
firewall-cmd --permanent --add-port=8181/tcp
# GLASSFISH ADMIN
firewall-cmd --permanent --add-port=4848/tcp
# SOLR
firewall-cmd --permanent --add-port=8983/tcp
# RSERVE
firewall-cmd --permanent --add-port=6311/tcp
# APACHE PROXY HTTP
firewall-cmd --permanent --add-port=80/tcp
# APACHE PROXY HTTPS
firewall-cmd --permanent --add-port=443/tcp
# AJP CONNECTOR
firewall-cmd --permanent --add-port=8009/tcp
firewall-cmd --reload
systemctl restart firewalld
# FIREWALLD STATUS
echo "${GREEN}Firewalld status!${RESET}"
systemctl status firewalld
# SECURE GLASSFISH
/usr/local/glassfish4/glassfish/bin/asadmin change-admin-password
/usr/local/glassfish4/glassfish/bin/asadmin --host localhost --port 4848 enable-secure-admin
echo "${GREEN}Restarting Glassfish!${RESET}"
systemctl restart glassfish
# SERVICE GLASSFISH STATUS
echo "${GREEN}Glassfish status!${RESET}"
systemctl status glassfish
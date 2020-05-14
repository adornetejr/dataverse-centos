#!/bin/bash
RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`
# INSTALL FIREWALLD
echo "${GREEN}Installing dependencies!${RESET}"
yum install firewalld nmap
systemctl start firewalld
# SENDMAIL
echo "${GREEN}Opening up port 25!${RESET}"
firewall-cmd --permanent --add-port=25/tcp
# GLASSFISH HTTP
echo "${GREEN}Opening up port 8080!${RESET}"
firewall-cmd --permanent --add-port=8080/tcp
# GLASSFISH HTTPS
echo "${GREEN}Opening up port 8181!${RESET}"
firewall-cmd --permanent --add-port=8181/tcp
# GLASSFISH ADMIN
echo "${GREEN}Opening up port 4848!${RESET}"
firewall-cmd --permanent --add-port=4848/tcp
# SOLR
echo "${GREEN}Opening up port 8983!${RESET}"
firewall-cmd --permanent --add-port=8983/tcp
# RSERVE
echo "${GREEN}Opening up port 6311!${RESET}"
firewall-cmd --permanent --add-port=6311/tcp
# APACHE PROXY HTTP
echo "${GREEN}Opening up port 80!${RESET}"
firewall-cmd --permanent --add-port=80/tcp
# APACHE PROXY HTTPS
echo "${GREEN}Opening up port 443!${RESET}"
firewall-cmd --permanent --add-port=443/tcp
# AJP CONNECTOR
echo "${GREEN}Opening up port 8009!${RESET}"
firewall-cmd --permanent --add-port=8009/tcp
echo "${GREEN}Firewalld reload configurations!${RESET}"
firewall-cmd --reload
# SECURE GLASSFISH
echo "${GREEN}Securing Glassfish!${RESET}"
/usr/local/glassfish4/glassfish/bin/asadmin change-admin-password
/usr/local/glassfish4/glassfish/bin/asadmin --host localhost --port 4848 enable-secure-admin
echo "${GREEN}Restarting Glassfish!${RESET}"
systemctl restart glassfish
# SERVICE GLASSFISH STATUS
echo "${GREEN}Glassfish status!${RESET}"
systemctl status glassfish
# FIREWALLD SYSTEM START
echo "${GREEN}Enabling Firewalld to start with the system!${RESET}"
systemctl enable firewalld
echo "${GREEN}Restarting Firewalld!${RESET}"
systemctl restart firewalld
# FIREWALLD STATUS
echo "${GREEN}Firewalld status!${RESET}"
systemctl status firewalld
echo " "
echo "${GREEN}Firewalld installed!${RESET}"
echo "Stage (10/10) done!"
echo "${RED}Ctrl+C${RESET} to stop or ${GREEN}Enter${RESET} to continue!"
read -e $X
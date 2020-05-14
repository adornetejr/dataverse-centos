#!/bin/bash
RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`
# INSTALL FIREWALLD
echo "${GREEN}Installing dependencies!${RESET}"
yum install firewalld nmap
systemctl start firewalld
# SSHD
echo "${GREEN}Opening up port 22 for sshd!${RESET}"
firewall-cmd --permanent --add-port=22/tcp
echo "${GREEN}Opening up port 2022 for sshd!${RESET}"
firewall-cmd --permanent --add-port=2022/tcp
# SENDMAIL
echo "${GREEN}Opening up port 25 for Sendmail!${RESET}"
firewall-cmd --permanent --add-port=25/tcp
# NTPD
echo "${GREEN}Opening up port 123 for ntpd!${RESET}"
firewall-cmd --permanent --add-port=123/tcp
# GLASSFISH HTTP
echo "${GREEN}Opening up port 8080 for Glassfish!${RESET}"
firewall-cmd --permanent --add-port=8080/tcp
# GLASSFISH HTTPS
echo "${GREEN}Opening up port 8181 for Glassfish!${RESET}"
firewall-cmd --permanent --add-port=8181/tcp
# GLASSFISH ADMIN
echo "${GREEN}Opening up port 4848 for Glassfish Admin!${RESET}"
firewall-cmd --permanent --add-port=4848/tcp
# SOLR
echo "${GREEN}Opening up port 8983 for Solr Indexing!${RESET}"
firewall-cmd --permanent --add-port=8983/tcp
# RSERVE
echo "${GREEN}Opening up port 6311 for Rserve!${RESET}"
firewall-cmd --permanent --add-port=6311/tcp
# AJP CONNECTOR
echo "${GREEN}Opening up port 8009 for Apache Jserve Proxy!${RESET}"
firewall-cmd --permanent --add-port=8009/tcp
# APACHE PROXY HTTP
echo "${GREEN}Opening up port 80 for Apache HTTP Proxy!${RESET}"
firewall-cmd --permanent --add-port=80/tcp
# APACHE PROXY HTTPS
echo "${GREEN}Opening up port 443 for Apache HTTPs Proxy!${RESET}"
firewall-cmd --permanent --add-port=443/tcp
# RELOAD CONFIG
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
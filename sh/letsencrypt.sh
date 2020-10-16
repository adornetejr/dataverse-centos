#!/bin/bash
DIR=$PWD
RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`
# INSTALL FIREWALLD
echo "${GREEN}Installing dependencies!${RESET}"
sudo yum install -y yum-utils
sudo yum-config-manager --enable rhui-REGION-rhel-server-extras rhui-REGION-rhel-server-optional
echo "${GREEN}Installing Certbot!${RESET}"
sudo yum install -y certbot python2-certbot-apache python-requests python-six python-urllib3
echo "${GREEN}Setting up Certificate!${RESET}"
sudo certbot --apache
echo "${GREEN}Setting up cronjob!${RESET}"
echo "0 0,12 * * * root python -c 'import random; import time; time.sleep(random.random() * 3600)' && certbot renew -q" | sudo tee -a /etc/crontab > /dev/null
# SERVICE APACHE RESTART
echo "${GREEN}Restarting Apache!${RESET}"
sudo systemctl restart httpd
sleep 2
echo "${GREEN}Apache status!${RESET}"
sudo systemctl status httpd
sleep 2
echo " "
echo "${GREEN}SSL Certificate installed!${RESET}"
echo "Stage (10/13) done!"
echo "${RED}Ctrl+C${RESET} to stop or ${GREEN}Enter${RESET} to continue!"
# read -e $X
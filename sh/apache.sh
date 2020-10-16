#!/bin/bash
DIR=$PWD
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)
echo "${GREEN}Stopping Apache!${RESET}"
sudo systemctl stop httpd
echo "${GREEN}Backing up SSL Certificates!${RESET}"
TIMESTAMP=$(date "+%Y.%m.%d-%H.%M.%S")
sudo /bin/cp -R /etc/httpd $DIR/backup/httpd-$TIMESTAMP
sudo /bin/cp -R /etc/pki/tls $DIR/backup/tls-$TIMESTAMP
echo "${GREEN}Removing old settings!${RESET}"
sudo yum remove -y httpd mod_ssl
echo "${GREEN}Installing dependencies!${RESET}"
sudo yum install -y httpd mod_ssl
sudo systemctl stop httpd
echo "${GREEN}Setting up Apache!${RESET}"
HOST=$(hostname --fqdn)
sudo /bin/mv /etc/httpd/conf.d/$HOST.conf /etc/httpd/conf.d/$HOST.conf.bkp
sudo sed "s/dataverse.c3.furg.br/$HOST/g" $DIR/conf/dataverse.conf >/etc/httpd/conf.d/$HOST.conf
sudo /bin/mv /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bkp
sudo sed "s/dataverse.c3.furg.br/$HOST/g" $DIR/conf/httpd.conf >/etc/httpd/conf/httpd.conf
echo "${GREEN}Generating new SSL Certificates!${RESET}"
sudo mkdir /etc/httpd/ssl
$DIR/cert/keygen.sh -y 3 -f -u root -g root -h $HOST -e https://$HOST/
sudo /bin/mv /etc/pki/tls/certs/$HOST.cer /etc/pki/tls/certs/$HOST.cer.bkp
sudo /bin/mv /etc/pki/tls/private/$HOST.key /etc/pki/tls/private/$HOST.key.bkp
sudo /bin/mv $DIR/sp-cert.pem /etc/pki/tls/certs/$HOST.cer
sudo /bin/mv $DIR/sp-key.pem /etc/pki/tls/private/$HOST.key
sudo restorecon -Rv /etc/pki/tls/certs
sudo restorecon -Rv /etc/pki/tls/private
#chown -R apache:apache /etc/httpd/ssl
#chmod -R 600 /etc/httpd/ssl
# APACHE SYSTEM START
echo "${GREEN}Enabling Apache to start with the system!${RESET}"
sudo systemctl enable httpd
# sudo systemctl start httpd
# HTTPD SERVICE
echo "${GREEN}Apache status!${RESET}"
sudo systemctl status httpd
echo "${GREEN}Apache will start with Shibboleth!${RESET}"
echo " "
echo "${GREEN}Apache installed!${RESET}"
echo "Stage (8/13) done!"
echo "${RED}Ctrl+C${RESET} to stop or ${GREEN}Enter${RESET} to continue!"
# read -e $X
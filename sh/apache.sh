#!/bin/bash
DIR=$PWD
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)
echo "${GREEN}Stopping Apache!${RESET}"
systemctl stop httpd
echo "${GREEN}Backing up SSL Certificates!${RESET}"
TIMESTAMP=$(date "+%Y.%m.%d-%H.%M.%S")
mv /etc/httpd/ssl /etc/httpd/ssl-$TIMESTAMP
echo "${GREEN}Removing old settings!${RESET}"
yum remove -y httpd mod_ssl
echo "${GREEN}Installing Apache!${RESET}"
yum install -y httpd mod_ssl
systemctl stop httpd
echo "${GREEN}Setting up Apache!${RESET}"
mkdir /etc/httpd/ssl
HOST=$(hostname --fqdn)
if [ -f "$DIR/cert/chain.$HOST.cer" ]; then
  cp $DIR/cert/chain.$HOST.cer /etc/httpd/ssl
else
  INSERT="# SSLCertificateChainFile"
  sed -i "s/SSLCertificateChainFile/$INSERT/g" $DIR/conf/ssl.conf
fi
if [ -f "$DIR/cert/root.$HOST.cer" ]; then
  cp $DIR/cert/root.$HOST.cer /etc/httpd/ssl
else
  INSERT="# SSLCACertificateFile"
  sed -i "s/SSLCACertificateFile/$INSERT/g" $DIR/conf/ssl.conf
fi
mv /etc/httpd/conf.d/$HOST.conf /etc/httpd/conf.d/$HOST.conf.bkp
sed "s/dataverse.c3.furg.br/$HOST/g" $DIR/conf/dataverse.conf >/etc/httpd/conf.d/$HOST.conf
mv /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bkp
sed "s/dataverse.c3.furg.br/$HOST/g" $DIR/conf/httpd.conf >/etc/httpd/conf/httpd.conf
mv etc/httpd/conf.d/ssl.conf etc/httpd/conf.d/ssl.conf.bkp
sed "s/dataverse.c3.furg.br/$HOST/g" $DIR/conf/ssl.conf >/etc/httpd/conf.d/ssl.conf
echo "${GREEN}Generating new SSL Certificates!${RESET}"
$DIR/cert/keygen.sh -y 3 -f -u root -g root -h $HOST -e https://$HOST/
mv $DIR/sp-cert.pem /etc/httpd/ssl/$HOST.cer
mv $DIR/sp-key.pem /etc/httpd/ssl/$HOST.key
chown root:root /etc/httpd/ssl/*
chmod 600 /etc/httpd/ssl/*
systemctl stop httpd
# APACHE SYSTEM START
echo "${GREEN}Enabling Apache to start with the system!${RESET}"
systemctl enable httpd
echo "${GREEN}Starting Apache!${RESET}"
systemctl start httpd
# HTTPD SERVICE
echo "${GREEN}Apache status!${RESET}"
systemctl status httpd

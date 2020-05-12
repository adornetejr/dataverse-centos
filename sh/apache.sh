#!/bin/bash
DIR=$PWD
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)
echo "${GREEN}Stopping Apache!${RESET}"
systemctl stop httpd
echo "${GREEN}Backing up SSL Certificates!${RESET}"
mv /etc/httpd/ssl /etc/httpd/ssl-bkp
mkdir /etc/httpd/ssl
if [ -f "$DIR/cert/chain.$HOST.cer" ]; then
  cp $DIR/cert/chain.$HOST.cer /etc/httpd/ssl
else
  sed "s/'SSLCertificateChainFile /etc'/'# SSLCertificateChainFile /etc'/g" $DIR/conf/ssl.conf >$DIR/conf/ssl.conf
fi
if [ -f "$DIR/cert/root.$HOST.cer" ]; then
  cp $DIR/cert/root.$HOST.cer /etc/httpd/ssl
else
  sed "s/'SSLCACertificateFile /etc'/'# SSLCACertificateFile /etc'/g" $DIR/conf/ssl.conf >$DIR/conf/ssl.conf
fi
echo "${GREEN}Removing old settings!${RESET}"
yum remove -y httpd mod_ssl
echo "${GREEN}Installing Apache!${RESET}"
yum install -y httpd mod_ssl
systemctl stop httpd
echo "${GREEN}Setting up Apache!${RESET}"
HOST=$(hostname --fqdn)
mv /etc/httpd/conf.d/$HOST.conf /etc/httpd/conf.d/$HOST.conf.bkp
sed "s/dataverse.c3.furg.br/$HOST/g" $DIR/conf/dataverse.conf >/etc/httpd/conf.d/$HOST.conf
mv /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bkp
sed "s/dataverse.c3.furg.br/$HOST/g" $DIR/conf/httpd.conf >/etc/httpd/conf/httpd.conf
mv etc/httpd/conf.d/ssl.conf etc/httpd/conf.d/ssl.conf.bkp
sed "s/dataverse.c3.furg.br/$HOST/g" $DIR/conf/ssl.conf >/etc/httpd/conf.d/ssl.conf
chown root:root /etc/httpd/ssl/*
chmod 600 /etc/httpd/ssl/*
echo "${GREEN}Generating new SSL Certificates!${RESET}"
cd $DIR/cert
./keygen.sh -y 3 -f -u root -g root -h $HOST -e https://$HOST/
mv sp-cert.pem /etc/httpd/ssl/$HOST.cer
mv sp-key.pem /etc/httpd/ssl/$HOST.key
systemctl stop httpd
# APACHE SYSTEM START
echo "${GREEN}Enabling Apache to start with the system!${RESET}"
systemctl enable httpd
echo "${GREEN}Starting Apache!${RESET}"
systemctl start httpd
# HTTPD SERVICE
echo "${GREEN}Apache status!${RESET}"
systemctl status httpd
#!/bin/bash
DIR=$PWD
HOST=$(hostname --fqdn)
echo "Stopping Apache!"
systemctl stop httpd
echo "Removing old settings!"
yum remove -y httpd mod_ssl
echo "Installing Apache!"
yum install -y httpd mod_ssl
systemctl stop httpd
echo "Setting up Apache!"
mv /etc/httpd/conf.d/$HOST.conf /etc/httpd/conf.d/$HOST.conf.bkp
sed "s/dataverse.c3.furg.br/$HOST/g" $DIR/conf/dataverse.conf >/etc/httpd/conf.d/$HOST.conf
mv etc/httpd/conf.d/ssl.conf etc/httpd/conf.d/ssl.conf.bkp
sed "s/dataverse.c3.furg.br/$HOST/g" $DIR/conf/ssl.conf >/etc/httpd/conf.d/ssl.conf
cp $DIR/conf/ssl.conf /etc/httpd/conf.d
mv /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bkp
sed "s/dataverse.c3.furg.br/$HOST/g" $DIR/conf/httpd.conf >/etc/httpd/conf/httpd.conf
mv /etc/httpd/ssl /etc/httpd/ssl-bkp
mkdir /etc/httpd/ssl
cp $DIR/cert/chain.$HOST.cer /etc/httpd/ssl
cp $DIR/cert/root.$HOST.cer /etc/httpd/ssl
chown root:root /etc/httpd/ssl/*
chmod 600 /etc/httpd/ssl/*
cd $DIR/cert
./keygen.sh -y 3 -f -u root -g root -h $HOST -e https://$HOST/
mv sp-cert.pem /etc/httpd/ssl/$HOST.cer
mv sp-key.pem /etc/httpd/ssl/$HOST.key
systemctl stop httpd
# APACHE SYSTEM START
echo "Enabling Apache to start with the system!"
systemctl enable httpd
echo "Starting Apache!"
systemctl start httpd
# HTTPD SERVICE
systemctl status httpd
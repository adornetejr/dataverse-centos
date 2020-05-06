#!/bin/bash
DIR=$PWD
systemctl stop httpd
yum remove -y httpd mod_ssl
yum install -y httpd mod_ssl
systemctl stop httpd
rm -rf etc/httpd/conf.d/dataverse.conf
cp $DIR/dataverse.conf /etc/httpd/conf.d
rm -rf etc/httpd/conf.d/ssl.conf
cp $DIR/ssl.conf /etc/httpd/conf.d
rm -rf etc/httpd/conf/httpd.conf
cp $DIR/httpd.conf /etc/conf
mkdir /etc/httpd/ssl
rm -rf /etc/httpd/ssl/root.furg.br.cer /etc/httpd/ssl/furg.br.cer /etc/httpd/ssl/$HOSTNAME.cer /etc/httpd/ssl/$HOSTNAME.key
cp $DIR/furg.br.cer /etc/httpd/ssl
cp $DIR/root.furg.br.cer /etc/httpd/ssl
chown root:root /etc/httpd/ssl/furg.br.cer
chmod 600 /etc/httpd/ssl/furg.br.cer
cd $DIR
chmod 744 keygen.sh
./keygen.sh -y 3 -f -u root -g root -h dataverse.c3.furg.br -e https://dataverse.c3.furg.br/
mv sp-cert.pem /etc/httpd/ssl/$HOSTNAME.cer
mv sp-key.pem /etc/httpd/ssl/$HOSTNAME.key
systemctl stop httpd
echo "Starting httpd!"
systemctl enable httpd
systemctl start httpd
# STATUS DO SERVICO HTTPD
systemctl status httpd
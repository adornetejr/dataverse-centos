#!/bin/bash
DIR=$PWD
systemctl stop httpd
yum remove -y httpd mod_ssl
rm -rf /etc/httpd
yum install -y httpd mod_ssl
echo "LoadModule rewrite_module modules/mod_rewrite.so" >> /etc/httpd/conf.modules.d/00-base.conf
sed 's/localdomain/'$HOSTNAME'/g' 080-default.conf > APACHE
echo $APACHE
rm -rf /etc/httpd/conf.d/080-default.conf
cp 080-default.conf /etc/httpd/conf.d
systemctl stop httpd
echo "Starting httpd!"
systemctl enable httpd
systemctl start httpd
# STATUS DO SERVICO HTTPD
systemctl status httpd
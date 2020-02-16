#!/bin/bash
DIR=$PWD
systemctl stop httpd
yum remove -y httpd mod_ssl
rm -rf /etc/httpd
yum install -y httpd mod_ssl
sed 's/localdomain/'$HOSTNAME'/g' 080-default.conf > 080-default.conf
rm -rf /etc/httpd/conf.d/080-default.conf
cp 080-default.conf /etc/httpd/conf.d
sed 's/localdomain/'$HOSTNAME'/g' 443-default.conf > 443-default.conf
rm -rf /etc/httpd/conf.d/443-default.conf
cp 443-default.conf /etc/httpd/conf.d
echo "Starting httpd!"
systemctl enable httpd
systemctl start httpd
# STATUS DO SERVICO HTTPD
systemctl status httpd
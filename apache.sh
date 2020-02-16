#!/bin/bash
DIR=$PWD
systemctl stop httpd
yum install -y httpd mod_ssl
sed 's/localdomain/'$HOSTANAME'/g' 080-default.conf
rm -rf /etc/httpd/conf.d/080-default.conf
cp 080-default.conf /etc/httpd/conf.d

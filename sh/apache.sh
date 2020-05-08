#!/bin/bash
DIR=$PWD
systemctl stop httpd
yum remove -y httpd mod_ssl
yum install -y httpd mod_ssl
systemctl stop httpd
HOST=$(hostname --fqdn)
echo "ServerName $HOST" >> $DIR/conf/dataverse.conf
echo "</VirtualHost>" >> $DIR/conf/dataverse.conf
rm -rf etc/httpd/conf.d/$HOST.conf
cp $DIR/conf/dataverse.conf /etc/httpd/conf.d/$HOST.conf
rm -rf etc/httpd/conf.d/ssl.conf
cp $DIR/conf/ssl.conf /etc/httpd/conf.d
rm -rf etc/httpd/conf/httpd.conf
cp $DIR/httpd.conf /etc/conf
mkdir /etc/httpd/ssl
rm -rf /etc/httpd/ssl/root.furg.br.cer /etc/httpd/ssl/furg.br.cer /etc/httpd/ssl/$HOST.cer /etc/httpd/ssl/$HOST.key
cp $DIR/cert/furg.br.cer /etc/httpd/ssl
cp $DIR/cert/root.furg.br.cer /etc/httpd/ssl
chown root:root /etc/httpd/ssl/furg.br.cer
chmod 600 /etc/httpd/ssl/furg.br.cer
cd $DIR
sh/keygen.sh -y 3 -f -u root -g root -h $HOST -e https://dataverse.c3.furg.br/
mv sp-cert.pem /etc/httpd/ssl/$HOST.cer
mv sp-key.pem /etc/httpd/ssl/$HOST.key
systemctl stop httpd
echo "Starting httpd!"
systemctl enable httpd
systemctl start httpd
# STATUS DO SERVICO HTTPD
systemctl status httpd
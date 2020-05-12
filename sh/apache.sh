#!/bin/bash
DIR=$PWD
systemctl stop httpd
yum remove -y httpd mod_ssl
yum install -y httpd mod_ssl
systemctl stop httpd
HOST=$(hostname --fqdn)
echo "ServerName $HOST" >>$DIR/conf/dataverse.conf
echo "</VirtualHost>" >>$DIR/conf/dataverse.conf
rm -rf etc/httpd/conf.d/$HOST.conf
cp $DIR/conf/dataverse.conf /etc/httpd/conf.d/$HOST.conf
cat $DIR/conf/shib.conf >>$DIR/conf/ssl.conf
echo "ServerName $HOST:443" >>$DIR/conf/ssl.conf
echo "SSLCertificateFile /etc/httpd/ssl/$HOST.cer" >>$DIR/conf/ssl.conf
echo "SSLCertificateKeyFile /etc/httpd/ssl/$HOST.key" >>$DIR/conf/ssl.conf
echo "SSLCertificateChainFile /etc/httpd/ssl/chain.$HOST.cer" >>$DIR/conf/ssl.conf
echo "SSLCACertificateFile /etc/httpd/ssl/root.$HOST.cer" >>$DIR/conf/ssl.conf
echo "</VirtualHost>" >>$DIR/conf/ssl.conf
rm -rf etc/httpd/conf.d/ssl.conf
cp $DIR/conf/ssl.conf /etc/httpd/conf.d
rm -rf etc/httpd/conf/httpd.conf
cp $DIR/httpd.conf /etc/conf
mkdir /etc/httpd/ssl
rm -rf /etc/httpd/ssl/root.$HOST.cer /etc/httpd/ssl/chain.$HOST.cer
cp $DIR/cert/chain.$HOST.cer /etc/httpd/ssl
cp $DIR/cert/root.$HOST.cer /etc/httpd/ssl
chown root:root /etc/httpd/ssl/*.cer
chmod 600 /etc/httpd/ssl/*.cer
rm -rf /etc/httpd/ssl/$HOST.cer /etc/httpd/ssl/$HOST.key
cd $DIR
sh/keygen.sh -y 3 -f -u root -g root -h $HOST -e https://$HOST/
mv sp-cert.pem /etc/httpd/ssl/$HOST.cer
mv sp-key.pem /etc/httpd/ssl/$HOST.key
systemctl stop httpd
echo "Starting httpd!"
systemctl enable httpd
systemctl start httpd
# STATUS DO SERVICO HTTPD
systemctl status httpd

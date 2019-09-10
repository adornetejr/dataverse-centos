
systemctl restart glassfish.service
cd /usr/local/glassfish4/glassfish/
bin/asadmin set server-config.network-config.network-listeners.network-listener.http-listener-1.port=80
systemctl restart glassfish.service


cd
cd dataverse-4.9.1/downloads
./download.sh
rm -rf dataverse-furg
git clone https://github.com/adornetejr/dataverse-furg

curl -X PUT -d root@dataverse.c3.furg.br http://localhost:8080/api/admin/settings/:SystemEmail

/usr/local/glassfish4/bin/asadmin list-applications
cd /usr/local/glassfish4/glassfish/
bin/asadmin --user admin --port 4848 change-admin-password
bin/asadmin --user admin --port 4848 enable-secure-admin
systemctl restart glassfish.service

cd /usr/local/glassfish4/glassfish/domains/domain1/applications/dataverse/WEB-INF/classes/
rm -rf Bundle.properties
wget https://raw.githubusercontent.com/adornetejr/dataverse-furg/master/Bundle.properties
systemctl restart glassfish.service
systemctl status glassfish.service
cd

systemctl start httpd.service
systemctl enable httpd.service
cd /etc/httpd/conf.modules.d/
rm -f 00-base.conf
wget https://raw.githubusercontent.com/adornetejr/dataverse-furg/master/00-base.conf
cd /etc/httpd/conf/
rm -f httpd.conf
wget https://raw.githubusercontent.com/adornetejr/dataverse-furg/master/httpd.conf
cd /var/www/html
rm -f .htaccess
wget https://raw.githubusercontent.com/adornetejr/dataverse-furg/master/htaccess -O .htaccess
cd /etc/httpd/conf.d/
echo "<VirtualHost *:80>" > 00-default.conf
echo "ProxyPreserveHost On" >> 00-default.conf
echo "ProxyPass / http://127.0.0.1:8080/" >> 00-default.conf
echo "ProxyPassReverse / http://127.0.0.1:8080/" >> 00-default.conf
echo "</VirtualHost>" >> 00-default.conf
systemctl restart httpd.service
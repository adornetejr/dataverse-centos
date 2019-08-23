########
rm -f anaconda-ks.cfg
yum update
yum install wget git net-tools
git clone https://github.com/adornetejr/dataverse-furg
wget http://download.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -ihv epel-release*
yum update
yum install nano curl htop lynx wget unzip nmap httpd mod_ssl lsof java-1.8.0-openjdk java-1.8.0-openjdk-devel ImageMagick sendmail sendmail-cf m4 R
cd /etc/
rm -f hosts
wget https://raw.githubusercontent.com/adornetejr/dataverse-furg/master/hosts
reboot
########
wget https://releases.hashicorp.com/vagrant/2.2.5/vagrant_2.2.5_x86_64.rpm
wget https://github.com/IQSS/dataverse/archive/v4.9.1.zip
wget https://github.com/IQSS/dataverse/releases/download/v4.9.1/dataverse-4.9.1.war
wget https://github.com/IQSS/dataverse/releases/download/v4.9.1/dvinstall.zip
unzip v4.9.1.zip
unzip dvinstall.zip
cp -R dvinstall /tmp/
cd dataverse-4.9.1/downloads
./download.sh
cd ../..
wget http://dlc-cdn.sun.com/glassfish/4.1/release/glassfish-4.1.zip
unzip glassfish-4.1.zip
mv glassfish4 /usr/local
chown -R root:root /usr/local/glassfish4
cd /usr/local/glassfish4/glassfish/modules
rm -f weld-osgi-bundle.jar
wget http://central.maven.org/maven2/org/jboss/weld/weld-osgi-bundle/2.2.10.SP1/weld-osgi-bundle-2.2.10.SP1-glassfish4.jar
cd /usr/local/glassfish4/glassfish/domains/domain1/config/
rm -f domain.xml
wget https://raw.githubusercontent.com/adornetejr/dataverse-furg/master/domain.xml
cp -f /usr/lib/jvm/java-1.8.0-openjdk/jre/lib/security/cacerts /usr/local/glassfish4/glassfish/domains/domain1/config/cacerts.jks
cd /usr/lib/systemd/system
rm -f glassfish.service
wget https://raw.githubusercontent.com/adornetejr/dataverse-furg/master/glassfish.service
systemctl daemon-reload
systemctl start glassfish.service
systemctl enable glassfish.service
cd /usr/bin
wget http://stedolan.github.io/jq/download/linux64/jq
chmod +x jq
jq --version
yum install -y https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-x86_64/pgdg-centos96-9.6-3.noarch.rpm
yum makecache fast
yum install -y postgresql96-server
/usr/pgsql-9.6/bin/postgresql96-setup initdb
/usr/bin/systemctl start postgresql-9.6
/usr/bin/systemctl enable postgresql-9.6
useradd solr
mkdir /usr/local/solr
chown solr:solr /usr/local/solr
su - solr
cd /usr/local/solr
rm -rf solr-7.3.0.tgz
wget https://archive.apache.org/dist/lucene/solr/7.3.0/solr-7.3.0.tgz
tar xvzf solr-7.3.0.tgz
cd solr-7.3.0
cp -r server/solr/configsets/_default server/solr/collection1
cp /tmp/dvinstall/schema.xml /usr/local/solr/solr-7.3.0/server/solr/collection1/conf
cp /tmp/dvinstall/solrconfig.xml /usr/local/solr/solr-7.3.0/server/solr/collection1/conf
cd /usr/local/solr/solr-7.3.0
bin/solr start
bin/solr create_core -c collection1 -d server/solr/collection1/conf/
exit
cd /usr/lib/systemd/system
rm -f solr.service
wget https://raw.githubusercontent.com/adornetejr/dataverse-furg/master/solr.service
systemctl daemon-reload
systemctl start solr.service
systemctl enable solr.service
cd /etc/security/
rm -f limits.conf
wget https://raw.githubusercontent.com/adornetejr/dataverse-furg/master/limits.conf
cd
systemctl start httpd.service
systemctl enable httpd.service
systemctl start firewalld.service
systemctl enable firewalld.service
firewall-cmd --permanent --add-port=80/tcp
systemctl restart firewalld.service
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
cd /etc/mail/
hostname >> /etc/mail/relay-domains
rm -f sendmail.mc
wget https://raw.githubusercontent.com/adornetejr/dataverse-furg/master/sendmail.mc
m4 /etc/mail/sendmail.mc > /etc/mail/sendmail.cf
systemctl restart sendmail.service









#########
sudo -i R
install.packages("R2HTML", repos="https://cloud.r-project.org/",lib="/usr/lib/R/library" )
install.packages("rjson", repos="https://cloud.r-project.org/",lib="/usr/lib/R/library" )
install.packages("DescTools", repos="https://cloud.r-project.org/",lib="/usr/lib/R/library" )
install.packages("Rserve", repos="https://cloud.r-project.org/",lib="/usr/lib/R/library" )
install.packages("haven", repos="https://cloud.r-project.org/",lib="/usr/lib/R/library" )
#########
su - postgres
psql
password 'pgginfo2019'
\q
exit
systemctl restart postgresql-9.6
#########
cd /usr/local/glassfish4/glassfish/
bin/asadmin --port 4848 change-admin-password
bin/asadmin --port 4848 enable-secure-admin
systemctl restart glassfish.service
senha==>'gfginfo2019'
#########
/usr/local/glassfish4/bin/asadmin list-applications





systemctl status glassfish.service
systemctl status postgresql-9.6

systemctl status glassfish.service
systemctl status glassfish.service


















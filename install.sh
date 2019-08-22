rm -f anaconda-ks.cfg
yum update
yum install wget git net-tools
git clone https://github.com/adornetejr/dataverse-furg
wget http://download.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -ihv epel-release*
yum update
yum install htop wget java-1.8.0-openjdk java-1.8.0-openjdk-devel unzip nmap nano
cd /etc/
rm hosts
wget https://github.com/adornetejr/dataverse-furg/blob/master/hosts
wget https://releases.hashicorp.com/vagrant/2.2.5/vagrant_2.2.5_x86_64.rpm
wget https://github.com/IQSS/dataverse/archive/v4.9.1.zip
unzip v4.9.1.zip
cd dataverse-4.9.1/downloads
./download.sh
cd ../..
wget http://dlc-cdn.sun.com/glassfish/4.1/release/glassfish-4.1.zip
unzip glassfish-4.1.zip
mv glassfish4 /usr/local
chown -R root:root /usr/local/glassfish4
cd /usr/local/glassfish4/glassfish/modules
rm weld-osgi-bundle.jar
wget http://central.maven.org/maven2/org/jboss/weld/weld-osgi-bundle/2.2.10.SP1/weld-osgi-bundle-2.2.10.SP1-glassfish4.jar
cd /usr/local/glassfish4/glassfish/domains/domain1/config/
rm domain.xml
wget https://github.com/adornetejr/dataverse-furg/blob/master/domain.xml
/usr/local/glassfish4/bin/asadmin start-domain
/usr/local/glassfish4/bin/asadmin osgi lb | grep 'Weld OSGi Bundle'





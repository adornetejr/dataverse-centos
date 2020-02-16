#!/bin/bash
DIR=$PWD
systemctl stop shibd
cd /etc/yum.repos.d
wget http://download.opensuse.org/repositories/security:/shibboleth/CentOS_7/security:shibboleth.repo
cd /usr/local/glassfish4/glassfish/modules/
mv glassfish-grizzly-extra-all.jar glassfish-grizzly-extra-all.jar.bkp
wget http://guides.dataverse.org/en/latest/_downloads/glassfish-grizzly-extra-all.jar
cd /usr/local/glassfish4/glassfish/bin/
systemctl start glassfish
./asadmin set-log-levels org.glassfish.grizzly.http.server.util.RequestUtils=SEVERE
./asadmin set server-config.network-config.network-listeners.network-listener.http-listener-1.port=8080
./asadmin set server-config.network-config.network-listeners.network-listener.http-listener-2.port=8181
./asadmin create-network-listener --protocol http-listener-1 --listenerport 8009 --jkenabled true jk-connector
./asadmin list-network-listeners
cd /etc/shibboleth
mv shibboleth2.xml shibboleth2.xml.bkp
cp $DIR/shibboleth2.xml .
mv attribute-map.xml attribute-map.xml.bkp
cp $DIR/attribute-map.xml .
systemctl enable shibd
systemctl start shibd
systemctl status shibd
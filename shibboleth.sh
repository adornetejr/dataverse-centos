#!/bin/bash
DIR=$PWD
systemctl stop shibd
cd /etc/yum.repos.d
wget http://download.opensuse.org/repositories/security:/shibboleth/CentOS_7/security:shibboleth.repo
yum install shibboleth
cd /usr/local/glassfish4/glassfish/modules/
mv glassfish-grizzly-extra-all.jar glassfish-grizzly-extra-all.jar.bkp
wget http://guides.dataverse.org/en/latest/_downloads/glassfish-grizzly-extra-all.jar
cd /usr/local/glassfish4/glassfish/bin/
./asadmin set server-config.network-config.network-listeners.network-listener.http-listener-1.port=8080
./asadmin set server-config.network-config.network-listeners.network-listener.http-listener-2.port=8181
./asadmin create-network-listener --protocol http-listener-1 --listenerport 8009 --jkenabled true jk-connector
./asadmin list-network-listeners
./asadmin set-log-levels org.glassfish.grizzly.http.server.util.RequestUtils=SEVERE
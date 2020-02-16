#!/bin/bash
DIR=$PWD
systemctl stop glassfish
systemctl stop shibd
yum remove -y shibboleth shibboleth-embedded-ds
rm -rf /etc/shibboleth
rm -rf /etc/yum.repos.d/security:shibboleth.repo*
cd /etc/yum.repos.d
wget http://download.opensuse.org/repositories/security:/shibboleth/CentOS_7/security:shibboleth.repo
yum install -y shibboleth shibboleth-embedded-ds
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
useradd shibd
chown -R root:root /etc/shibboleth
rm -rf *.pem
./keygen.sh -y 3 -f -u shibd -g shibd -h dataverse.c3.furg.br -e https://dataverse.c3.furg.br/shibboleth
mv sp-cert.pem sp-encrypt-cert.pem
mv sp-key.pem sp-encrypt-key.pem
./keygen.sh -y 3 -f -u shibd -g shibd -h dataverse.c3.furg.br -e https://dataverse.c3.furg.br/shibboleth
mv sp-cert.pem sp-signing-cert.pem
mv sp-key.pem sp-signing-key.pem
rm -rf /etc/selinux/targeted/src/policy/domains/misc/shibboleth.te
cp $DIR/shibboleth.te /etc/selinux/targeted/src/policy/domains/misc
cd /etc/selinux/targeted/src/policy/domains/misc
checkmodule -M -m -o shibboleth.mod shibboleth.te
semodule_package -o shibboleth.pp -m shibboleth.mod
semodule -i shibboleth.pp
cd $DIR
curl -X POST -H 'Content-type: application/json' --upload-file shibAuthProvider.json http://127.0.0.1:8080/api/admin/authenticationProviders
systemctl enable shibd
systemctl restart httpd.service
systemctl restart shibd
systemctl status shibd
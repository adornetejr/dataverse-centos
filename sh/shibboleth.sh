#!/bin/bash
DIR=$PWD
RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`
HOST=$(hostname --fqdn)
echo "${GREEN}Stopping Glassfish!${RESET}"
systemctl stop glassfish
echo "${GREEN}Stopping Shibboleth!${RESET}"
systemctl stop shibd
echo "${GREEN}Removing old settings!${RESET}"
TIMESTAMP=$(date "+%Y.%m.%d-%H.%M.%S")
mv /etc/shibboleth /etc/shibboleth-$TIMESTAMP
# SHIBBOLETH REPOSITORY
echo "${GREEN}Installing Shibboleth repository!${RESET}"
rm -rf /etc/yum.repos.d/security:shibboleth.repo*
wget http://download.opensuse.org/repositories/security:/shibboleth/CentOS_7/security:shibboleth.repo -P /etc/yum.repos.d
yum install -y shibboleth shibboleth-embedded-ds
mv /usr/local/glassfish4/glassfish/modules/glassfish-grizzly-extra-all.jar /usr/local/glassfish4/glassfish/modules/glassfish-grizzly-extra-all.jar.bkp
wget http://guides.dataverse.org/en/latest/_downloads/glassfish-grizzly-extra-all.jar -P /usr/local/glassfish4/glassfish/modules/
echo "${GREEN}Starting Glassfish!${RESET}"
systemctl start glassfish
echo "${GREEN}Setting up Shibboleth!${RESET}"
/usr/local/glassfish4/glassfish/bin/asadmin set-log-levels org.glassfish.grizzly.http.server.util.RequestUtils=SEVERE
/usr/local/glassfish4/glassfish/bin/asadmin set server-config.network-config.network-listeners.network-listener.http-listener-1.port=8080
/usr/local/glassfish4/glassfish/bin/asadmin set server-config.network-config.network-listeners.network-listener.http-listener-2.port=8181
/usr/local/glassfish4/glassfish/bin/asadmin create-network-listener --protocol http-listener-1 --listenerport 8009 --jkenabled true jk-connector
/usr/local/glassfish4/glassfish/bin/asadmin list-network-listeners
mv /etc/shibboleth/shibboleth2.xml /etc/shibboleth/shibboleth2.xml.bkp
cp $DIR/xml/shibboleth2.xml /etc/shibboleth/shibboleth2.xml
mv /etc/shibboleth/attribute-map.xml /etc/shibboleth/attribute-map.xml.bkp
cp $DIR/xml/attribute-map.xml /etc/shibboleth/attribute-map.xml
useradd shibd
usermod -s /sbin/nologin shibd
chown -R root:root /etc/shibboleth
for FILE in $(find /etc/shibboleth -name '*.pem')
do
  mv $FILE $(echo "$FILE" | sed -r 's|.pem|.pem.bkp|g')
done
cp $DIR/cert/keygen.sh /etc/shibboleth/keygen.sh
cd $DIR/cert
./keygen.sh -y 3 -f -u shibd -g shibd -h $HOST -e "https://$HOST/shibboleth"
mv sp-cert.pem /etc/shibboleth/sp-encrypt-cert.pem
mv sp-key.pem /etc/shibboleth/sp-encrypt-key.pem
./keygen.sh -y 3 -f -u shibd -g shibd -h $HOST -e "https://$HOST/shibboleth"
mv sp-cert.pem /etc/shibboleth/sp-signing-cert.pem
mv sp-key.pem /etc/shibboleth/sp-signing-key.pem
mv /etc/selinux/targeted/src/policy/domains/misc/shibboleth.te /etc/selinux/targeted/src/policy/domains/misc/shibboleth.te.bkp
cp $DIR/shib/shibboleth.te /etc/selinux/targeted/src/policy/domains/misc/shibboleth.te
cd /etc/selinux/targeted/src/policy/domains/misc
checkmodule -M -m -o shibboleth.mod shibboleth.te
semodule_package -o shibboleth.pp -m shibboleth.mod
semodule -i shibboleth.pp
curl -X POST -H 'Content-type: application/json' --upload-file $DIR/shib/shibAuthProvider.json http://127.0.0.1:8080/api/admin/authenticationProviders
# SHIBBOLETH SYSTEM START
systemctl enable shibd
echo "${GREEN}Starting Shibboleth!${RESET}"
systemctl start shibd
# SERVICE SHIBBOLETH STATUS
echo "${GREEN}Shibboleth status!${RESET}"
systemctl status shibd
echo "${GREEN}Restarting Glassfish!${RESET}"
systemctl restart glassfish
# SERVICE SHIBBOLETH STATUS
echo "${GREEN}Glassfish status!${RESET}"
systemctl status glassfish
echo "${GREEN}Restarting Apache!${RESET}"
systemctl restart httpd
echo "${GREEN}Apache status!${RESET}"
systemctl status httpd
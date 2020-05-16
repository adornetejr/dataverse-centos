#!/bin/bash
DIR=$PWD
RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`
echo "${GREEN}Stopping Glassfish!${RESET}"
systemctl stop glassfish
echo "${GREEN}Stopping Apache!${RESET}"
systemctl stop httpd
echo "${GREEN}Stopping Shibboleth!${RESET}"
systemctl stop shibd
echo "${GREEN}Backing up old installation!${RESET}"
TIMESTAMP=$(date "+%Y.%m.%d-%H.%M.%S")
/bin/cp -R /etc/shibboleth $DIR/backup/shibboleth-$TIMESTAMP
echo "${GREEN}Removing old settings!${RESET}"
yum remove -y shibboleth shibboleth-embedded-ds
# SHIBBOLETH REPOSITORY
echo "${GREEN}Installing Shibboleth repository!${RESET}"
rm -rf /etc/yum.repos.d/security:shibboleth.repo.*
wget http://download.opensuse.org/repositories/security:/shibboleth/CentOS_7/security:shibboleth.repo -P /etc/yum.repos.d
yum install -y shibboleth shibboleth-embedded-ds opensaml log4shib xerces-c xml-security-c xmltooling unixODBC
mv /usr/local/glassfish4/glassfish/modules/glassfish-grizzly-extra-all.jar /usr/local/glassfish4/glassfish/modules/glassfish-grizzly-extra-all.jar.bkp
wget http://guides.dataverse.org/en/latest/_downloads/glassfish-grizzly-extra-all.jar -P /usr/local/glassfish4/glassfish/modules/
mv /etc/shibboleth/shibboleth2.xml /etc/shibboleth/shibboleth2.xml.bkp
mv /etc/shibboleth/attribute-map.xml /etc/shibboleth/attribute-map.xml.bkp
echo "${GREEN}Starting Glassfish!${RESET}"
systemctl start glassfish
sleep 10
echo "${GREEN}Setting up Shibboleth!${RESET}"
/usr/local/glassfish4/glassfish/bin/asadmin set-log-levels org.glassfish.grizzly.http.server.util.RequestUtils=SEVERE
/usr/local/glassfish4/glassfish/bin/asadmin set server-config.network-config.network-listeners.network-listener.http-listener-1.port=8080
/usr/local/glassfish4/glassfish/bin/asadmin set server-config.network-config.network-listeners.network-listener.http-listener-2.port=8181
/usr/local/glassfish4/glassfish/bin/asadmin create-network-listener --protocol http-listener-1 --listenerport 8009 --jkenabled true jk-connector
/usr/local/glassfish4/glassfish/bin/asadmin list-network-listeners
until [[ ! -z "$NAME" && ! -z "$SURNAME" && ! -z "$EMAIL" ]]; do
  clear
  echo "${GREEN}Shibboleth Support Contact${RESET}"
  read -ep "First Name: " NAME
  read -ep "Surname: " SURNAME
  read -ep "Email: " EMAIL
done
HOST=$(hostname --fqdn)
sed -i "s/Adornete/$NAME/g" $DIR/xml/shibboleth2.xml
sed -i "s/Martins Jr/$SURNAME/g" $DIR/xml/shibboleth2.xml
sed -i "s/ginfo@furg.br/$EMAIL/g" $DIR/xml/shibboleth2.xml
sed "s/dataverse.c3.furg.br/$HOST/g" $DIR/xml/shibboleth2.xml >/etc/shibboleth/shibboleth2.xml
cp $DIR/xml/attribute-map.xml /etc/shibboleth/attribute-map.xml
mv /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.bkp
sed "s/dataverse.c3.furg.br/$HOST/g" $DIR/conf/ssl.conf >/etc/httpd/conf.d/ssl.conf
useradd shibd
usermod -s /sbin/nologin shibd
chown -R root:root /etc/shibboleth
touch /etc/shibboleth/sys.logger
echo "${GREEN}Generating new SSL Certificates!${RESET}"
for FILE in $(find /etc/shibboleth -name '*.pem')
do
  mv $FILE $(echo "$FILE" | sed -r 's/.pem/.pem.bkp/g')
done
cp $DIR/cert/keygen.sh /etc/shibboleth/keygen.sh
$DIR/cert/keygen.sh -y 3 -f -u shibd -g shibd -h $HOST -e "https://$HOST/shibboleth"
mv $DIR/sp-cert.pem /etc/shibboleth/sp-encrypt-cert.pem
mv $DIR/sp-key.pem /etc/shibboleth/sp-encrypt-key.pem
$DIR/cert/keygen.sh -y 3 -f -u shibd -g shibd -h $HOST -e "https://$HOST/shibboleth"
mv $DIR/sp-cert.pem /etc/shibboleth/sp-signing-cert.pem
mv $DIR/sp-key.pem /etc/shibboleth/sp-signing-key.pem
chmod 644 /etc/shibboleth/*pem
echo "${GREEN}Setting up SELinux Module for Shibboleth!${RESET}"
mkdir -p /etc/selinux/targeted/src/policy/domains/misc
mv /etc/selinux/targeted/src/policy/domains/misc/shibboleth.te /etc/selinux/targeted/src/policy/domains/misc/shibboleth.te.bkp
cp $DIR/semodule/shibboleth.te /etc/selinux/targeted/src/policy/domains/misc/shibboleth.te
cd /etc/selinux/targeted/src/policy/domains/misc
checkmodule -M -m -o shibboleth.mod shibboleth.te
semodule_package -o shibboleth.pp -m shibboleth.mod
semodule -i shibboleth.pp
# SERVICE GLASSFISH RESTART
echo "${GREEN}Restarting Glassfish!${RESET}"
systemctl restart glassfish
sleep 10
echo "${GREEN}Setting up login button!${RESET}"
curl -X POST -H 'Content-type: application/json' --upload-file $DIR/json/shibAuthProvider.json http://127.0.0.1:8080/api/admin/authenticationProviders
# SERVICE GLASSFISH STATUS
echo "${GREEN}Restarting Glassfish!${RESET}"
systemctl restart httpd
sleep 10
echo "${GREEN}Glassfish status!${RESET}"
systemctl status glassfish
sleep 2
# SERVICE APACHE RESTART
echo "${GREEN}Restarting Apache!${RESET}"
systemctl restart httpd
sleep 2
echo "${GREEN}Apache status!${RESET}"
systemctl status httpd
sleep 2
# SHIBBOLETH SYSTEM START
echo "${GREEN}Enabling Shibboleth to start with the system!${RESET}"
systemctl enable shibd
echo "${GREEN}Starting Shibboleth!${RESET}"
systemctl start shibd
sleep 4
# SERVICE SHIBBOLETH STATUS
echo "${GREEN}Shibboleth status!${RESET}"
systemctl status shibd
echo " "
echo "${GREEN}Shibboleth installed!${RESET}"
echo "Stage (9/10) done!"
echo "${RED}Ctrl+C${RESET} to stop or ${GREEN}Enter${RESET} to continue!"
read -e $X
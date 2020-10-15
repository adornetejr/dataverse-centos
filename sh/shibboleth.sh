#!/bin/bash
DIR=$PWD
RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`
echo "${GREEN}Stopping Glassfish!${RESET}"
sudo systemctl stop glassfish
echo "${GREEN}Stopping Apache!${RESET}"
sudo systemctl stop httpd
echo "${GREEN}Stopping Shibboleth!${RESET}"
sudo systemctl stop shibd
echo "${GREEN}Backing up old installation!${RESET}"
TIMESTAMP=$(date "+%Y.%m.%d-%H.%M.%S")
sudo /bin/cp -R /etc/shibboleth $DIR/backup/shibboleth-$TIMESTAMP
echo "${GREEN}Removing old settings!${RESET}"
sudo yum remove -y shibboleth shibboleth-embedded-ds
# SHIBBOLETH REPOSITORY
echo "${GREEN}Installing Shibboleth repository!${RESET}"
sudo rm -rf /etc/yum.repos.d/security:shibboleth.repo*
sudo wget http://download.opensuse.org/repositories/security:/shibboleth/CentOS_7/security:shibboleth.repo -P /etc/yum.repos.d
sudo yum install -y shibboleth shibboleth-embedded-ds opensaml log4shib xerces-c xml-security-c xmltooling unixODBC
sudo /bin/mv -f /usr/local/glassfish4/glassfish/modules/glassfish-grizzly-extra-all.jar /usr/local/glassfish4/glassfish/modules/glassfish-grizzly-extra-all.jar.bkp
sudo wget http://guides.dataverse.org/en/latest/_downloads/glassfish-grizzly-extra-all.jar -P /usr/local/glassfish4/glassfish/modules/
sudo /bin/cp -f /etc/shibboleth/shibboleth2.xml /etc/shibboleth/shibboleth2.xml.bkp
sudo /bin/cp -f /etc/shibboleth/attribute-map.xml /etc/shibboleth/attribute-map.xml.bkp
echo "${GREEN}Starting Glassfish!${RESET}"
sudo systemctl start glassfish
sleep 10
echo "${GREEN}Setting up Shibboleth!${RESET}"
sudo /usr/local/glassfish4/glassfish/bin/asadmin set-log-levels org.glassfish.grizzly.http.server.util.RequestUtils=SEVERE
sudo /usr/local/glassfish4/glassfish/bin/asadmin set server-config.network-config.network-listeners.network-listener.http-listener-1.port=8080
sudo /usr/local/glassfish4/glassfish/bin/asadmin set server-config.network-config.network-listeners.network-listener.http-listener-2.port=8181
sudo /usr/local/glassfish4/glassfish/bin/asadmin create-network-listener --protocol http-listener-1 --listenerport 8009 --jkenabled true jk-connector
sudo /usr/local/glassfish4/glassfish/bin/asadmin list-network-listeners
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
sed -i "s/dataverse.c3.furg.br/$HOST/g" $DIR/xml/shibboleth2.xml
sudo /bin/cp -f $DIR/xml/shibboleth2.xml /etc/shibboleth/shibboleth2.xml
sudo /bin/cp -f $DIR/xml/attribute-map.xml /etc/shibboleth/attribute-map.xml
sudo /bin/cp -f /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.bkp
sed -i "s/dataverse.c3.furg.br/$HOST/g" $DIR/conf/ssl.conf
sudo /bin/cp -f $DIR/conf/ssl.conf /etc/httpd/conf.d/ssl.conf
sudo useradd shibd
sudo usermod -s /sbin/nologin shibd
sudo chown -R root:root /etc/shibboleth
sudo touch /etc/shibboleth/sys.logger
echo "${GREEN}Generating new SSL Certificates!${RESET}"
for FILE in $(find /etc/shibboleth -name '*.pem')
do
  sudo /bin/mv $FILE $(echo "$FILE" | sed -r 's/.pem/.pem.bkp/g')
done
sudo /bin/cp -f $DIR/cert/keygen.sh /etc/shibboleth/keygen.sh
sudo $DIR/cert/keygen.sh -y 3 -f -u shibd -g shibd -h $HOST -e "https://$HOST/shibboleth"
sudo /bin/mv $DIR/sp-cert.pem /etc/shibboleth/sp-encrypt-cert.pem
sudo /bin/mv $DIR/sp-key.pem /etc/shibboleth/sp-encrypt-key.pem
sudo $DIR/cert/keygen.sh -y 3 -f -u shibd -g shibd -h $HOST -e "https://$HOST/shibboleth"
sudo /bin/mv $DIR/sp-cert.pem /etc/shibboleth/sp-signing-cert.pem
sudo /bin/mv $DIR/sp-key.pem /etc/shibboleth/sp-signing-key.pem
sudo chmod 644 /etc/shibboleth/*pem
echo "${GREEN}Setting up SELinux Module for Shibboleth!${RESET}"
sudo mkdir -p /etc/selinux/targeted/src/policy/domains/misc
sudo /bin/cp -f /etc/selinux/targeted/src/policy/domains/misc/shibboleth.te /etc/selinux/targeted/src/policy/domains/misc/shibboleth.te.bkp
sudo /bin/cp -f $DIR/semodule/shibboleth.te /etc/selinux/targeted/src/policy/domains/misc/shibboleth.te
cd /etc/selinux/targeted/src/policy/domains/misc
sudo checkmodule -M -m -o shibboleth.mod shibboleth.te
sudo semodule_package -o shibboleth.pp -m shibboleth.mod
sudo semodule -i shibboleth.pp
# SERVICE GLASSFISH RESTART
echo "${GREEN}Restarting Glassfish!${RESET}"
sudo systemctl restart payara.service
sleep 15
echo "${GREEN}Setting up login button!${RESET}"
curl -X POST -H 'Content-type: application/json' --upload-file $DIR/json/shibAuthProvider.json http://127.0.0.1:8080/api/admin/authenticationProviders
echo " "
# SERVICE GLASSFISH STATUS
echo "${GREEN}Restarting Glassfish!${RESET}"
sudo systemctl restart httpd
sleep 10
echo "${GREEN}Glassfish status!${RESET}"
sudo systemctl status glassfish
sleep 2
# SERVICE APACHE RESTART
echo "${GREEN}Restarting Apache!${RESET}"
sudo systemctl restart httpd
sleep 2
echo "${GREEN}Apache status!${RESET}"
sudo systemctl status httpd
sleep 2
# SHIBBOLETH SYSTEM START
echo "${GREEN}Enabling Shibboleth to start with the system!${RESET}"
sudo systemctl enable shibd
echo "${GREEN}Starting Shibboleth!${RESET}"
sudo systemctl start shibd
sleep 4
# SERVICE SHIBBOLETH STATUS
echo "${GREEN}Shibboleth status!${RESET}"
sudo systemctl status shibd
echo " "
echo "${GREEN}Shibboleth installed!${RESET}"
echo "Stage (9/13) done!"
echo "${RED}Ctrl+C${RESET} to stop or ${GREEN}Enter${RESET} to continue!"
read -e $X

#!/bin/bash
DIR=$PWD
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)
echo "${GREEN}Backing up logs!${RESET}"
mv $DIR/logs/install.log $DIR/logs/install.log.bkp
mv $DIR/logs/install.err $DIR/logs/install.err.bkp
# SERVICE FIREWALLD STOP
echo "${GREEN}Stopping Firewalld!${RESET}"
systemctl stop firewalld
systemctl disable firewalld
# INSTALL FEDORA REPOSITORY
echo "${GREEN}Installing Fedora repository!${RESET}"
yum install -y epel-release
# UPDATE PACKAGES
echo "${GREEN}Updating installed packages!${RESET}"
yum update -y
# INSTALL RECOMMENDED PACKAGES
echo "${GREEN}Installing dependencies!${RESET}"
yum install -y nano htop wget git net-tools lynx unzip curl libcurl nmap
# CHECKING HOST FILE
until [ $OP != "y" ]; do
    clear
    echo "${GREEN}Available networks${RESET}"
    ip -f inet address
    echo " "
    echo "${GREEN}File /etc/hostname:${RESET}"
    cat /etc/hostname
    echo " "
    echo "${GREEN}File /etc/hosts:${RESET}"
    cat /etc/hosts
    echo " "
    echo "${RED}Attention!!${RESET}"
    echo " "
    echo "1. /etc/hostname: Needs Fully Qualified Domain Name"
    echo "2. /etc/hosts: External IP needs to point to FQDN!"
    echo " "
    read -ep "${GREEN}Confirm and continue? (y/N): ${RESET}" OP
    if [ "$OP" != "y" ]; then
        echo "Correct the files /etc/hosts and /etc/hostname"
        echo "Press Enter after ajust"
        read -e $X
    else
        break
    fi
done
HOST=$(hostname --fqdn)
echo "HOST_DNS_ADDRESS    $HOST" >$DIR/default.config
cd $DIR
chmod 744 sh/*.sh
sh/sendmail.sh
cd $DIR
sh/glassfish.sh
cd $DIR
sh/solr.sh
cd $DIR
sh/rserve.sh
cd $DIR
sh/counter.sh
cd $DIR
sh/postgresql.sh
cd $DIR
sh/dataverse.sh
cd $DIR
sh/apache.sh
cd $DIR
sh/shibboleth.sh
cd $DIR
sh/firewalld.sh
echo "${GREEN}Backing up Metadata${RESET}"
META="https://$HOST/Shibboleth.sso/Metadata"
wget $META -P $DIR --no-check-certificate
echo "$DIR/Metadata"
rm -rf $DIR/default.config /tmp/dvinstall/default.config
clear
echo "${GREEN}Installation completed!${RESET}"
echo " "
echo "Execute letsencrypt command to create a SSL certificate"
echo "$ sudo bash sh/letsencrypt.sh"
echo " "
echo "${RED}Attention!!${RESET}"
echo " "
echo "Send this file to atendimento@rnp.br"
echo "Link: $META"
echo " "
echo "Read more ${RED}http://hdl.handle.net/20.500.11959/1264${RESET}"
echo " "
echo "Reboot the system to test services startup!"
read -e $X
#!/bin/bash
DIR=$PWD
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)
echo "${GREEN}Updating submodules!${RESET}"
git reset --hard
git pull
git submodule init
git submodule update --force
echo "${GREEN}Backing up logs!${RESET}"
/bin/mv  $DIR/logs/install.log $DIR/logs/install.log.bkp
/bin/mv  $DIR/logs/install.err $DIR/logs/install.err.bkp
# INSTALL FEDORA REPOSITORY
echo "${GREEN}Installing Fedora repository!${RESET}"
sudo yum install -y epel-release
# UPDATE PACKAGES
echo "${GREEN}Updating installed packages!${RESET}"
sudo yum update -y
# INSTALL RECOMMENDED PACKAGES
echo "${GREEN}Installing dependencies!${RESET}"
sudo yum install -y nano htop wget git net-tools nmap unzip curl libcurl curl-openssl policycoreutils-python
echo "${GREEN}Setting SELinux open ports!${RESET}"
# SETTING SELINUX
sudo semanage port -a -t ntp_port_t -p udp 123
sudo semanage port -a -t postgresql_port_t -p tcp 5432
# sudo semanage port -a -t http_port_t -p tcp 8983
# sudo semanage port -a -t http_port_t -p tcp 6311
# sudo semanage port -a -t http_port_t -p tcp 8009
# sudo semanage port -a -t http_port_t -p tcp 8080
# sudo semanage port -a -t http_port_t -p tcp 8181
# sudo semanage port -a -t http_port_t -p tcp 4848
sudo semanage port -a -t http_port_t -p tcp 80
sudo semanage port -a -t http_port_t -p tcp 443
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
sh/letsencrypt.sh
cd $DIR
sh/language.sh
cd $DIR
sh/doi.sh
cd $DIR
sh/firewalld.sh
echo "${GREEN}Backing up Metadata${RESET}"
META="https://$HOST/Shibboleth.sso/Metadata"
wget $META -P $DIR --no-check-certificate
echo "$DIR/Metadata"
sudo rm -rf $DIR/default.config /tmp/dvinstall/default.config
sleep 4
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
echo " "
#!/bin/bash
DIR=$PWD
RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`
echo "${GREEN}Removing old settings!${RESET}"
mv $DIR/default.config $DIR/default.config.bkp
mv $DIR/logs/install.out $DIR/logs/install.out.bkp
mv $DIR/logs/install.err $DIR/logs/install.err.bkp
# SERVICE FIREWALLD STOP
systemctl stop firewalld
# INSTALL FEDORA REPOSITORY
echo "${GREEN}Installing Fedora repository!${RESET}"
yum install -y epel-release
# UPDATE PACKAGES
echo "${GREEN}Updating installed packages!${RESET}"
yum update -y
# INSTALL RECOMMENDED PACKAGES
echo "${GREEN}Installing dependencies!${RESET}"
yum install -y nano htop wget git net-tools lynx unzip curl
cd $DIR
chmod 744 sh/*.sh
sh/sendmail.sh
echo " "
echo "${GREEN}Sendmail installed!${RESET}"
echo "Stage (1/10) done!"
echo "${RED}Ctrl+C${RESET} to stop or ${GREEN}Enter${RESET} to continue!"
# read -e $X
sh/glassfish.sh
echo " "
echo "${GREEN}Glassfish installed!${RESET}"
echo "Stage (2/10) done!"
echo "${RED}Ctrl+C${RESET} to stop or ${GREEN}Enter${RESET} to continue!"
# read -e $X
cd $DIR
sh/solr.sh
echo " "
echo "${GREEN}Solr installed!${RESET}"
echo "Stage (3/10) done!"
echo "${RED}Ctrl+C${RESET} to stop or ${GREEN}Enter${RESET} to continue!"
# read -e $X
cd $DIR
sh/postgresql.sh
echo " "
echo "${GREEN}Postgres installed!${RESET}"
echo "Stage (4/10) done!"
echo "${RED}Ctrl+C${RESET} to stop or ${GREEN}Enter${RESET} to continue!"
# read -e $X
cd $DIR
sh/rserve.sh
echo " "
echo "${GREEN}Rserve installed!${RESET}"
echo "Stage (5/10) done!"
echo "${RED}Ctrl+C${RESET} to stop or ${GREEN}Enter${RESET} to continue!"
# read -e $X
cd $DIR
sh/counter.sh
echo " "
echo "${GREEN}Counter-Processor installed!${RESET}"
echo "Stage (6/10) done!"
echo "${RED}Ctrl+C${RESET} to stop or ${GREEN}Enter${RESET} to continue!"
# read -e $X
cd $DIR
sh/dataverse.sh
echo " "
echo "${GREEN}Dataverse installed!${RESET}"
echo "Stage (7/10) done!"
echo "${RED}Ctrl+C${RESET} to stop or ${GREEN}Enter${RESET} to continue!"
read -e $X
cd $DIR
sh/apache.sh
echo " "
echo "${GREEN}Apache installed!${RESET}"
echo "Stage (8/10) done!"
echo "${RED}Ctrl+C${RESET} to stop or ${GREEN}Enter${RESET} to continue!"
read -e $X
cd $DIR
sh/shibboleth.sh
echo " "
echo "${GREEN}Shibboleth installed!${RESET}"
echo "Stage (9/10) done!"
echo "${RED}Ctrl+C${RESET} to stop or ${GREEN}Enter${RESET} to continue!"
read -e $X
cd $DIR
sh/firewalld.sh
rm -rf $DIR/default.config /tmp/dvinstall/default.config
clear
echo " "
echo "${GREEN}Firewalld installed!${RESET}"
echo "Stage (10/10) done!"
echo " "
echo "Installation completed!"
echo " "
echo "${GREEN}Attention!!${RESET}"
echo " "
echo "Faça a relação de confiança para o login federado funcionar!"
echo " "
echo "Saiba mais em ${RED}http://hdl.handle.net/20.500.11959/1264${RESET}"
echo ""
# read -e $X

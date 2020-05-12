#!/bin/bash
DIR=$PWD
echo "Removing old settings!"
mv $DIR/default.config $DIR/default.config.bkp
mv $DIR/logs/install.out $DIR/logs/install.out.bkp
mv $DIR/logs/install.err $DIR/logs/install.err.bkp
# INSTALL FEDORA REPOSITORY
echo "Installing Fedora repository!"
yum install -y epel-release
# UPDATE PACKAGES
echo "Updating installed packages!"
yum update -y
# INSTALL RECOMMENDED PACKAGES
echo "Installing dependencies!"
yum install -y nano htop wget git net-tools lynx unzip curl
cd $DIR
chmod 744 sh/*.sh
sh/sendmail.sh
echo " "
echo "Stage (1/9) done!"
echo "Ctrl+C to cancel or Enter to continue!"
read -e $X
cd $DIR
sh/glassfish.sh
echo " "
echo "Stage (2/9) done!"
echo "Ctrl+C to cancel or Enter to continue!"
read -e $X
cd $DIR
sh/solr.sh
echo " "
echo "Stage (3/9) done!"
echo "Ctrl+C to cancel or Enter to continue!"
read -e $X
cd $DIR
sh/postgresql.sh
echo " "
echo "Stage (4/9) done!"
echo "Ctrl+C to cancel or Enter to continue!"
read -e $X
cd $DIR
sh/rserve.sh
echo " "
echo "Stage (5/9) done!"
echo "Ctrl+C to cancel or Enter to continue!"
read -e $X
cd $DIR
sh/counter.sh
echo " "
echo "Stage (6/9) done!"
echo "Ctrl+C to cancel or Enter to continue!"
read -e $X
cd $DIR
sh/dataverse.sh
echo " "
echo "Stage (7/9) done!"
echo "Ctrl+C to cancel or Enter to continue!"
read -e $X
cd $DIR
sh/apache.sh
echo " "
echo "Stage (8/9) done!"
echo "Ctrl+C to cancel or Enter to continue!"
read -e $X
cd $DIR
sh/shibboleth.sh
rm -rf $DIR/default.config /tmp/dvinstall/default.config
clear
echo " "
echo "Stage (9/9) done!"
echo "Installation completed!"
echo " "
echo "Attention!!"
echo "Faça a relação de confiança para o login federado funcionar!"
echo " "
echo "Saiba mais em http://hdl.handle.net/20.500.11959/1264"
echo " "
read -e $X
#!/bin/bash
DIR=$PWD
echo "Removing old settings!"
mv $DIR/default.config $DIR/default.config.bkp
mv $DIR/logs/install.out $DIR/logs/install.out.bkp
mv $DIR/logs/install.err $DIR/logs/install.err.bkp
# UPDATE PACKAGES
echo "Updating packages!"
yum update -y
# INSTALL FEDORA REPOSITORY
echo "Installing Fedora repository!"
yum install -y epel-release
yum makecache fast
# UPDATE PACKAGES
echo "Updating packages!"
yum update -y
# INSTALL RECOMMENDED PACKAGES
echo "Installing dependencies!"
yum install -y nano htop wget git net-tools lynx unzip curl
# DOWNLOAD DATAVERSE
echo "Downloading Dataverse!"
FILE="dvinstall.zip"
LOCATION="/tmp/$FILE"
LINK=https://github.com/IQSS/dataverse/releases/download/v4.19/dvinstall.zip
cd /tmp/
# REMOVE OLD INSTALATION
rm -rf /tmp/dvinstall
if [ -f "$LOCATION" ]; then
    ls $LOCATION
    if [ "$(md5sum $LOCATION)" == "de4f375f0c68c404e8adc52092cb8334  $LOCATION" ]; then
        unzip $FILE
    else
        rm $LOCATION
        wget $LINK
        unzip $FILE
    fi
else
    wget $LINK
    unzip $FILE
fi
echo " "
echo "Stage (1/10) done!"
echo "Ctrl+C to cancel or Enter to continue!"
read -e $X
cd $DIR
chmod 744 sh/*.sh
sh/sendmail.sh
echo " "
echo "Stage (2/10) done!"
echo "Ctrl+C to cancel or Enter to continue!"
read -e $X
cd $DIR
sh/glassfish.sh
echo " "
echo "Stage (3/10) done!"
echo "Ctrl+C to cancel or Enter to continue!"
read -e $X
cd $DIR
sh/solr.sh
echo " "
echo "Stage (4/10) done!"
echo "Ctrl+C to cancel or Enter to continue!"
read -e $X
cd $DIR
sh/postgresql.sh
echo " "
echo "Stage (5/10) done!"
echo "Ctrl+C to cancel or Enter to continue!"
read -e $X
cd $DIR
sh/rserve.sh
echo " "
echo "Stage (6/10) done!"
echo "Ctrl+C to cancel or Enter to continue!"
read -e $X
cd $DIR
sh/counter.sh
echo " "
echo "Stage (7/10) done!"
echo "Ctrl+C to cancel or Enter to continue!"
read -e $X
cd $DIR
sh/dataverse.sh
echo " "
echo "Stage (8/10) done!"
echo "Ctrl+C to cancel or Enter to continue!"
read -e $X
cd $DIR
sh/apache.sh
echo " "
echo "Stage (9/10) done!"
echo "Ctrl+C to cancel or Enter to continue!"
read -e $X
cd $DIR
sh/shibboleth.sh
rm -rf $DIR/default.config /tmp/dvinstall/default.config
echo " "
echo "Stage (10/10) done!"
echo "Installation completed!"
echo " "
echo "Attention!!"
echo "Faça a relação de confiança para o login federado funcionar!"
echo " "
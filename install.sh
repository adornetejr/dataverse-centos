#!/bin/bash
DIR=$PWD
# ATUALIZA PACOTES
yum update -y
# INSTALA REPOSITORIO EPEL FEDORA NO CENTOS 7
cd /tmp/
rm -rf epel-release-latest-7.noarch.rpm
wget http://download.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y epel-release-latest-7.noarch.rpm
# ATUALIZA PACOTES
yum makecache fast
# INSTALA PACOTES OBRIGATORIOS
yum install -y wget unzip curl mod_ssl lsof java-1.8.0-openjdk java-1.8.0-openjdk-devel ImageMagick sendmail sendmail-cf m4 R
# INSTALA PACOTES OPCIONAIS
yum install -y nano lynx net-tools git htop 
# ALTERANDO ARQUIVO HOSTS PARA CONFIGURACAO LOCAL DO SENTMAIL
cd /etc/
rm -f hosts
wget https://raw.githubusercontent.com/adornetejr/dataverse-furg/master/hosts
# CONFIGURA SENDMAIL
cd /etc/mail/
hostname >> /etc/mail/relay-domains
rm -f sendmail.mc
wget https://raw.githubusercontent.com/adornetejr/dataverse-furg/master/sendmail.mc
m4 /etc/mail/sendmail.mc > /etc/mail/sendmail.cf
systemctl restart sendmail.service
# DOWNLOAD DOS PACOTES DE INSTALACAO DO DATAVERSE
cd /tmp/
rm -rf v4.9.1.zip dvinstall.zip
# wget https://github.com/IQSS/dataverse/archive/v4.9.1.zip
wget https://github.com/IQSS/dataverse/releases/download/v4.9.1/dvinstall.zip
# REMOVE AS PASTAS ANTES DE DESCOMPACTAR
rm -rf dvinstall
unzip dvinstall.zip
cd $DIR
echo $DIR
echo $PWD
# EXECUTA SCRIPT DE INSTALACAO DO DATAVERSE
#
# SE O SCRIPT TRANCAR EM 'Updates Done. Retarting...'
# ABRA OUTRO TERMINAL E REINICIE O GLASSFISH
# $ systemctl restart glassfish.service
#
# cd /tmp/dvinstall
# rm -rf default.config
# wget https://raw.githubusercontent.com/adornetejr/dataverse-furg/master/default.config
# ./install
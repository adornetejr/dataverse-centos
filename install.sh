#!/bin/bash
DIR=$PWD
# ATUALIZA PACOTES
yum update -y
# INSTALA REPOSITORIO EPEL FEDORA NO CENTOS 7
epel="/tmp/epel-release-latest-7.noarch.rpm"
cd /tmp/
if [ -f "$epel" ]
then
    ls $epel
else
    wget http://download.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
fi
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
cp $DIR/hosts .
# CONFIGURA SENDMAIL
cd /etc/mail/
hostname >> /etc/mail/relay-domains
rm -f sendmail.mc
cp $DIR/sendmail.mc .
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
echo "Etapa (1/7) concluida!"
echo "Pressione Ctrl+C para cancelar e Enter para continuar!"
read -e $X
cd $DIR
chmod 744 glassfish.sh
./glassfish.sh
echo "Etapa (2/7) concluida!"
echo "Pressione Ctrl+C para cancelar e Enter para continuar!"
read -e $X
cd $DIR
chmod 744 jq.sh
./jq.sh
echo "Etapa (3/7) concluida!"
echo "Pressione Ctrl+C para cancelar e Enter para continuar!"
read -e $X
cd $DIR
chmod 744 solr.sh
./solr.sh
echo "Etapa (4/7) concluida!"
echo "Pressione Ctrl+C para cancelar e Enter para continuar!"
read -e $X
cd $DIR
chmod 744 postgresql.sh
./postgresql.sh
echo "Etapa (5/7) concluida!"
echo "Pressione Ctrl+C para cancelar e Enter para continuar!"
read -e $X
cd $DIR
chmod 744 rserve.sh
./rserve.sh
echo "Etapa (6/7) concluida!"
echo " "
echo "ATENÇÃO!!"
echo " "
echo "Se a próxima etapa trancar em 'Updates Done. Retarting...' por mais de 30 segundos."
echo " "
echo "Abra outro terminal e execute o comando:"
echo "$ systemctl restart glassfish.service"
echo " "
echo "Pressione Ctrl+C para cancelar e Enter para continuar!"
read -e $X
# EXECUTA SCRIPT DE INSTALACAO DO DATAVERSE
#
# SE O SCRIPT TRANCAR EM 'Updates Done. Retarting...'
# ABRA OUTRO TERMINAL E REINICIE O GLASSFISH
# $ systemctl restart glassfish.service
#
cd /tmp/dvinstall
rm -rf default.config
cp $DIR/default.config .
./install
echo "Etapa (7/7) concluida!"
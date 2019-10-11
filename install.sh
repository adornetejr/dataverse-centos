#!/bin/bash
DIR=$PWD
# ATUALIZA PACOTES
yum update -y
# INSTALA REPOSITORIO EPEL FEDORA NO CENTOS 7
yum install -y epel-release
# ATUALIZA PACOTES
yum makecache fast
# INSTALA PACOTES OBRIGATORIOS
yum install -y wget unzip curl mod_ssl lsof java-1.8.0-openjdk java-1.8.0-openjdk-devel ImageMagick sendmail sendmail-cf m4 R
# INSTALA PACOTES OPCIONAIS
yum install -y nano lynx net-tools git htop 
# ALTERANDO ARQUIVO HOSTS PARA CONFIGURACAO LOCAL DO SENTMAIL
echo "IP Address"
ip -f inet address | grep inet
echo "Hostname"
hostname
echo "Altere os parametros do arquivo /etc/hosts com as informações acima!"
echo "Após, pressione Enter para continuar!"
read -e $X
# CONFIGURA SENDMAIL
hostname >> /etc/mail/relay-domains
rm -f /etc/mail/sendmail.mc
cp $DIR/sendmail.mc /etc/mail/
m4 /etc/mail/sendmail.mc > /etc/mail/sendmail.cf
systemctl restart sendmail.service
# DOWNLOAD DOS PACOTES DE INSTALACAO DO DATAVERSE
dvinstall="/tmp/dvinstall.zip"
link=https://github.com/IQSS/dataverse/releases/download/v4.9.1/dvinstall.zip
cd /tmp/
if [ -f "$dvinstall" ]
then
    ls $dvinstall
    md5sum $dvinstall
else
    wget $link
fi
# REMOVE AS PASTAS ANTES DE DESCOMPACTAR
rm -rf /tmp/dvinstall
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
clear
echo "Etapa (6/7) concluida!"
echo " "
echo "ATENÇÃO!!"
echo " "
echo "Se a próxima etapa trancar em 'Updates Done. Retarting...' por mais de 30 segundos."
echo " "
echo "Abra outro terminal e execute o comando:"
echo "# systemctl restart glassfish.service"
echo " "
echo "Pressione Ctrl+C para cancelar e Enter para continuar!"
read -e $X
# EXECUTA SCRIPT DE INSTALACAO DO DATAVERSE
#
# SE O SCRIPT TRANCAR EM 'Updates Done. Retarting...'
# ABRA OUTRO TERMINAL E REINICIE O GLASSFISH
# $ systemctl restart glassfish.service
#
HOST=hostname
echo "HOST_DNS_ADDRESS    $HOST"
echo "GLASSFISH_DIRECTORY	/usr/local/glassfish4"
echo "GLASSFISH_USER	glassfish"
echo "ADMIN_EMAIL	root@$HOST"
echo "MAIL_SERVER	$HOST"
echo "POSTGRES_ADMIN_PASSWORD	ROOT_SECRET"
echo "POSTGRES_SERVER	127.0.0.1"
echo "POSTGRES_PORT	5432"
echo "POSTGRES_DATABASE	dvndb"
echo "POSTGRES_USER	dvnapp"
echo "POSTGRES_PASSWORD	USER_SECRET"
echo "SOLR_LOCATION	localhost:8983"
echo "TWORAVENS_LOCATION	NOT INSTALLED"
echo "RSERVE_HOST	localhost"
echo "RSERVE_PORT	6311"
echo "RSERVE_USER	rserve"
echo "RSERVE_PASSWORD	rserve"
cd /tmp/dvinstall
rm -rf default.config
cp $DIR/default.config .
./install
echo "Etapa (7/7) concluida!"
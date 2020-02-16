#!/bin/bash
DIR=$PWD
# ATUALIZA PACOTES
yum update -y
# INSTALA REPOSITORIO EPEL FEDORA NO CENTOS 7
yum install -y epel-release
# ATUALIZA PACOTES
yum update -y
yum makecache fast
# INSTALA PACOTES OBRIGATORIOS E RECOMENDADOS
yum install -y nano htop wget git net-tools lynx unzip curl
# DOWNLOAD DO PACOTE DE INSTALACAO DO DATAVERSE
dvinstall="/tmp/dvinstall.zip"
link=https://github.com/IQSS/dataverse/releases/download/v4.19/dvinstall.zip
cd /tmp/
# REMOVE AS PASTAS ANTES DE DESCOMPACTAR
rm -rf /tmp/dvinstall
if [ -f "$dvinstall" ]; then
    ls $dvinstall
    if [ "$(md5sum $dvinstall)" == "de4f375f0c68c404e8adc52092cb8334  /tmp/dvinstall.zip" ]; then
        unzip dvinstall.zip
    else
        rm $dvinstall
        wget $link
        unzip dvinstall.zip
    fi
fi
echo "Etapa (1/10) concluida!"
echo "Pressione Ctrl+C para cancelar e Enter para continuar!"
read -e $X
cd $DIR
chmod 744 sendmail.sh
./sendmail.sh
echo "Etapa (2/10) concluida!"
echo "Pressione Ctrl+C para cancelar e Enter para continuar!"
read -e $X
cd $DIR
chmod 744 glassfish.sh
./glassfish.sh
echo "Etapa (3/10) concluida!"
echo "Pressione Ctrl+C para cancelar e Enter para continuar!"
read -e $X
cd $DIR
chmod 744 solr.sh
./solr.sh
echo "Etapa (4/10) concluida!"
echo "Pressione Ctrl+C para cancelar e Enter para continuar!"
read -e $X
cd $DIR
chmod 744 postgresql.sh
./postgresql.sh
echo "Etapa (5/10) concluida!"
echo "Pressione Ctrl+C para cancelar e Enter para continuar!"
read -e $X
cd $DIR
chmod 744 rserve.sh
./rserve.sh
echo "Etapa (6/10) concluida!"
echo "Pressione Ctrl+C para cancelar e Enter para continuar!"
read -e $X
cd $DIR
chmod 744 counter.sh
./counter.sh
echo "Etapa (7/10) concluida!"
echo "Pressione Ctrl+C para cancelar e Enter para continuar!"
read -e $X
cd $DIR
chmod 744 dataverse.sh
./dataverse.sh
echo "Etapa (8/10) concluida!"
echo "Pressione Ctrl+C para cancelar e Enter para continuar!"
read -e $X
cd $DIR
chmod 744 apache.sh
./apache.sh
echo "Etapa (9/10) concluida!"
echo "Pressione Ctrl+C para cancelar e Enter para continuar!"
read -e $X
cd $DIR
chmod 744 shibboleth.sh
./shibboleth.sh
echo "Etapa (10/10) concluida!"
echo "Instalação concluida!"
echo "Faça a relação de confiança para o login federado funcionar!"
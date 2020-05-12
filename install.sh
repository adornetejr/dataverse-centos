#!/bin/bash
DIR=$PWD
rm -rf $DIR/default.config
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
FILE="dvinstall.zip"
LOCATION="/tmp/$FILE"
LINK=https://github.com/IQSS/dataverse/releases/download/v4.19/dvinstall.zip
cd /tmp/
# REMOVE AS PASTAS ANTES DE DESCOMPACTAR
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
echo "Etapa (1/10) concluida!"
echo "Pressione Ctrl+C para cancelar e Enter para continuar!"
read -e $X
cd $DIR
chmod 744 sh/*.sh
sh/sendmail.sh
echo "Etapa (2/10) concluida!"
echo "Pressione Ctrl+C para cancelar e Enter para continuar!"
read -e $X
cd $DIR
sh/glassfish.sh
echo "Etapa (3/10) concluida!"
echo "Pressione Ctrl+C para cancelar e Enter para continuar!"
read -e $X
cd $DIR
sh/solr.sh
echo "Etapa (4/10) concluida!"
echo "Pressione Ctrl+C para cancelar e Enter para continuar!"
read -e $X
cd $DIR
sh/postgresql.sh
echo "Etapa (5/10) concluida!"
echo "Pressione Ctrl+C para cancelar e Enter para continuar!"
read -e $X
cd $DIR
sh/rserve.sh
echo "Etapa (6/10) concluida!"
echo "Pressione Ctrl+C para cancelar e Enter para continuar!"
read -e $X
cd $DIR
sh/counter.sh
echo "Etapa (7/10) concluida!"
echo "Pressione Ctrl+C para cancelar e Enter para continuar!"
read -e $X
cd $DIR
sh/dataverse.sh
echo "Etapa (8/10) concluida!"
echo "Pressione Ctrl+C para cancelar e Enter para continuar!"
read -e $X
cd $DIR
sh/apache.sh
echo "Etapa (9/10) concluida!"
echo "Pressione Ctrl+C para cancelar e Enter para continuar!"
read -e $X
cd $DIR
sh/shibboleth.sh
echo "Etapa (10/10) concluida!"
echo "Instalação concluida!"
echo "Faça a relação de confiança para o login federado funcionar!"

#!/bin/bash
DIR=$PWD
systemctl stop solr
yum install -y lsof
echo "Baixando Solr!"
# DOWNLOAD DEPENDENCIA SOLR
FILE="solr-7.3.1.tgz"
LOCATION="/tmp/$FILE"
LINK=https://archive.apache.org/dist/lucene/solr/7.3.1/solr-7.3.1.tgz
rm -rf solr-7.3.1
rm -rf /usr/local/solr
if [ -f "$LOCATION" ]; then
    ls $LOCATION
    if [ "$(md5sum $LOCATION)" == "042a6c0d579375be1a8886428f13755f  $LOCATION" ]; then
        tar xvfz $FILE -C /tmp
    else
        rm $LOCATION
        wget $LINK -P /tmp
        tar xvfz $FILE -C /tmp
    fi
else
    wget $LINK -P /tmp
    tar xvfz $FILE -C /tmp
fi
echo "Configurando Solr!"
# CRIA PASTA DE INSTALAÇÃO
mkdir /usr/local/solr
cp -rf solr-7.3.1 /usr/local/solr
# ADICIONA USUARIO solr
useradd solr
# CONFIGURA ARQUIVOS SOLR DE ACORDO COM DATAVERSE
# cd /usr/local/solr/solr-7.3.1
cp -r server/solr/configsets/_default server/solr/collection1
cp /tmp/dvinstall/schema.xml /usr/local/solr/solr-7.3.1/server/solr/collection1/conf
cp /tmp/dvinstall/solrconfig.xml /usr/local/solr/solr-7.3.1/server/solr/collection1/conf
chown -R solr:solr /usr/local/solr
# REMOVE LIMITS
mv /etc/security/limits.conf /etc/security/limits.conf.bkp
cp $DIR/conf/limits.conf /etc/security/limits.conf
# ATIVA SERVICO SOLR PARA INICIALIZAR COM SISTEMA
mv /usr/lib/systemd/system/solr.service /usr/lib/systemd/system/solr.service.bkp
cp $DIR/service/solr.service /usr/lib/systemd/system/
systemctl daemon-reload
echo "name=collection1" >/usr/local/solr/solr-7.3.1/server/solr/collection1/core.properties
echo "SOLR_LOCATION	127.0.0.1:8983" >>$DIR/default.config
echo "TWORAVENS_LOCATION	NOT INSTALLED" >>$DIR/default.config
# START SOLR
echo "Habilitando Solr para iniciar com o sistema!"
systemctl enable solr
echo "Iniciando Solr!"
systemctl start solr
# STATUS SERVICE SOLR
systemctl status solr
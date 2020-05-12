#!/bin/bash
DIR=$PWD
systemctl stop solr
yum install -y lsof
# DOWNLOAD DEPENDENCIA SOLR
FILE="solr-7.3.1.tgz"
LOCATION="/tmp/$FILE"
LINK=https://archive.apache.org/dist/lucene/solr/7.3.1/solr-7.3.1.tgz
cd /tmp/
rm -rf solr-7.3.1
rm -rf /usr/local/solr
if [ -f "$LOCATION" ]; then
    ls $LOCATION
    if [ "$(md5sum $LOCATION)" == "042a6c0d579375be1a8886428f13755f  $LOCATION" ]; then
        tar -C /tmp xvfz $FILE
    else
        rm $LOCATION
        wget $LINK -P /tmp
        tar -C /tmp xvfz $FILE
    fi
else
    wget $LINK -P /tmp
    tar -C /tmp xvfz $FILE
fi

# CRIA PASTA DE INSTALAÇÃO
mkdir /usr/local/solr
cp -rf solr-7.3.1 /usr/local/solr
# ADICIONA USUARIO solr
useradd solr
# CONFIGURA ARQUIVOS SOLR DE ACORDO COM DATAVERSE
cd /usr/local/solr/solr-7.3.1
cp -r server/solr/configsets/_default server/solr/collection1
cp /tmp/dvinstall/schema.xml /usr/local/solr/solr-7.3.1/server/solr/collection1/conf
cp /tmp/dvinstall/solrconfig.xml /usr/local/solr/solr-7.3.1/server/solr/collection1/conf
chown -R solr:solr /usr/local/solr
# REMOVE LIMITS 
rm -f /etc/security/limits.conf
cp $DIR/conf/limits.conf /etc/security/
# ATIVA SERVICO SOLR PARA INICIALIZAR COM SISTEMA
rm -f /usr/lib/systemd/system/solr.service
cp $DIR/service/solr.service /usr/lib/systemd/system/
systemctl daemon-reload
echo "name=collection1" > /usr/local/solr/solr-7.3.1/server/solr/collection1/core.properties
echo "SOLR_LOCATION	127.0.0.1:8983" >> $DIR/default.config
echo "TWORAVENS_LOCATION	NOT INSTALLED" >> $DIR/default.config
echo "Starting solr!"
systemctl enable solr
systemctl start solr
# INICIA SOLR
sudo -u solr /usr/local/solr/solr-7.3.1/bin/solr create_core -c collection1 -d server/solr/collection1/conf/
systemctl status solr


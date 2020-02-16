#!/bin/bash
DIR=$PWD
systemctl stop solr
yum install -y lsof
# DOWNLOAD DEPENDENCIA SOLR
solr="/tmp/solr-7.3.1.tgz"
link=https://archive.apache.org/dist/lucene/solr/7.3.1/solr-7.3.1.tgz
cd /tmp/
rm -rf solr-7.3.1
rm -rf /usr/local/solr
if [ -f "$solr" ]; then
    ls $solr
    if [ "$(md5sum $solr)" == "042a6c0d579375be1a8886428f13755f  /tmp/solr-7.3.1.tgz" ]; then
        tar xvzf solr-7.3.1.tgz
    else
        rm $solr
        wget $link
        tar xvzf solr-7.3.1.tgz
    fi
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
cp $DIR/limits.conf /etc/security/
# ATIVA SERVICO SOLR PARA INICIALIZAR COM SISTEMA
rm -f /usr/lib/systemd/system/solr.service
cp $DIR/solr.service /usr/lib/systemd/system/
systemctl daemon-reload
echo "name=collection1" > /usr/local/solr/solr-7.3.1/server/solr/collection1/core.properties
echo "SOLR_LOCATION	127.0.0.1:8983" >> default.config
echo "TWORAVENS_LOCATION	NOT INSTALLED" >> default.config
echo "Starting solr!"
systemctl enable solr
systemctl start solr
# INICIA SOLR
sudo -u solr /usr/local/solr/solr-7.3.1/bin/solr create_core -c collection1 -d server/solr/collection1/conf/
systemctl status solr


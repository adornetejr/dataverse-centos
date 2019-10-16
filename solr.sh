#!/bin/bash
DIR=$PWD
systemctl stop solr.service
# DOWNLOAD DEPENDENCIA SOLR
solr="/tmp/solr-7.3.0.tgz"
link=https://archive.apache.org/dist/lucene/solr/7.3.0/solr-7.3.0.tgz
cd /tmp/
if [ -f "$solr" ]
then
    ls $solr
    md5sum $solr
else
    wget $link
fi
rm -rf solr-7.3.0
tar xvzf solr-7.3.0.tgz
# CRIA PASTA DE INSTALAÇÃO
mkdir /usr/local/solr
rm -rf /usr/local/solr/solr-7.3.0
cp -rf solr-7.3.0 /usr/local/solr
# ADICIONA USUARIO solr
useradd solr
# CONFIGURA ARQUIVOS SOLR DE ACORDO COM DATAVERSE
cd /usr/local/solr/solr-7.3.0
cp -r server/solr/configsets/_default server/solr/collection1
cp /tmp/dvinstall/schema.xml /usr/local/solr/solr-7.3.0/server/solr/collection1/conf
cp /tmp/dvinstall/solrconfig.xml /usr/local/solr/solr-7.3.0/server/solr/collection1/conf
chown -R solr:solr /usr/local/solr
# REMOVE LIMITS 
rm -f /etc/security/limits.conf
cp $DIR/limits.conf /etc/security/
# ATIVA SERVICO SOLR PARA INICIALIZAR COM SISTEMA
rm -f /usr/lib/systemd/system/solr.service
cp $DIR/solr.service /usr/lib/systemd/system/
systemctl daemon-reload
echo "Starting solr!"
systemctl start solr.service
systemctl enable solr.service
# INICIA SOLR
sudo -u solr /usr/local/solr/solr-7.3.0/bin/solr create_core -c collection1 -d server/solr/collection1/conf/
sleep 30
systemctl status solr.service
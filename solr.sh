#!/bin/bash
DIR=$PWD
# CRIA PASTA DE INSTALAÇÃO
mkdir /usr/local/solr
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
mkdir /usr/local/solr
rm -rf /usr/local/solr/solr-7.3.0
cp -rf solr-7.3.0 /usr/local/solr
# CONFIGURA ARQUIVOS SOLR DE ACORDO COM DATAVERSE
cd /usr/local/solr/solr-7.3.0
cp -rf server/solr/configsets/_default server/solr/collection1
cp -f /tmp/dvinstall/schema.xml /usr/local/solr/solr-7.3.0/server/solr/collection1/conf
cp -f /tmp/dvinstall/solrconfig.xml /usr/local/solr/solr-7.3.0/server/solr/collection1/conf
# ADICIONA USUARIO solr
useradd solr
chown -R solr:solr /usr/local/solr
# REMOVE LIMITS 
cd /etc/security/
rm -f limits.conf
cp $DIR/limits.conf .
# INICIA SOLR
sudo -u solr /usr/local/solr/solr-7.3.0/bin/solr start
sudo -u solr /usr/local/solr/solr-7.3.0/bin/solr create_core -c collection1 -d server/solr/collection1/conf/
# ATIVA SERVICO SOLR PARA INICIALIZAR COM SISTEMA
cd /usr/lib/systemd/system
rm -f solr.service
cp $DIR/solr.service .
systemctl daemon-reload
systemctl start solr.service
systemctl enable solr.service
systemctl status solr.service
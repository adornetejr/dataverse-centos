#!/bin/bash
# CRIA PASTA DE INSTALAÇÃO
mkdir /usr/local/solr
# DOWNLOAD DEPENDENCIA SOLR
cd /usr/local/solr
rm -rf solr-7.3.0.tgz
wget https://archive.apache.org/dist/lucene/solr/7.3.0/solr-7.3.0.tgz
tar xvzf solr-7.3.0.tgz
cd solr-7.3.0
# CONFIGURA ARQUIVOS SOLR DE ACORDO COM DATAVERSE
cp -r server/solr/configsets/_default server/solr/collection1
cp /tmp/dvinstall/schema.xml /usr/local/solr/solr-7.3.0/server/solr/collection1/conf
cp /tmp/dvinstall/solrconfig.xml /usr/local/solr/solr-7.3.0/server/solr/collection1/conf
cd /usr/local/solr/solr-7.3.0
# INICIA SOLR
bin/solr start
bin/solr create_core -c collection1 -d server/solr/collection1/conf/
# ADICIONA USUARIO solr
useradd solr
chown solr:solr /usr/local/solr
# ATIVA SERVICO SOLR PARA INICIALIZAR COM SISTEMA
cd /usr/lib/systemd/system
rm -f solr.service
wget https://raw.githubusercontent.com/adornetejr/dataverse-furg/master/solr.service
systemctl daemon-reload
systemctl start solr.service
systemctl enable solr.service
# REMOVE LIMITS 
cd /etc/security/
rm -f limits.conf
wget https://raw.githubusercontent.com/adornetejr/dataverse-furg/master/limits.conf
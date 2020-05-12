#!/bin/bash
DIR=$PWD
echo "Parando Solr!"
systemctl stop solr
echo "Instalando dependências!"
yum install -y lsof
# REMOVENDO CONFIGURAÇÕES ANTIGAS SOLR
echo "Removendo configurações antigas!"
rm -rf /tmp/solr-7.3.1
TIMESTAMP=$(date "+%Y.%m.%d-%H.%M.%S")
mv /usr/local/solr /usr/local/solr-$TIMESTAMP
# DOWNLOAD DEPENDENCIA SOLR
echo "Baixando Solr!"
FILE="solr-7.3.1.tgz"
LOCATION="/tmp/$FILE"
LINK=https://archive.apache.org/dist/lucene/solr/7.3.1/solr-7.3.1.tgz
if [ -f "$LOCATION" ]; then
    ls $LOCATION
    if [ "$(md5sum $LOCATION)" == "042a6c0d579375be1a8886428f13755f  $LOCATION" ]; then
        tar xvfz $LOCATION -C /tmp
    else
        rm $LOCATION
        wget $LINK -P /tmp
        tar xvfz $LOCATION -C /tmp
    fi
else
    wget $LINK -P /tmp
    tar xvfz $LOCATION -C /tmp
fi
echo "Configurando Solr!"
# CRIA PASTA DE INSTALAÇÃO
mkdir /usr/local/solr
cp -rf /tmp/solr-7.3.1 /usr/local/solr
sudo -u solr /usr/local/solr/solr-7.3.1/bin/solr delete -c collection1
# CONFIGURA ARQUIVOS SOLR DE ACORDO COM DATAVERSE
cp -rf /usr/local/solr/solr-7.3.1/server/solr/configsets/_default /usr/local/solr/solr-7.3.1/server/solr/collection1
wget https://raw.githubusercontent.com/IQSS/dataverse/v4.19/conf/solr/7.3.1/schema.xml -P /usr/local/solr/solr-7.3.1/server/solr/collection1/conf
wget https://raw.githubusercontent.com/IQSS/dataverse/v4.19/conf/solr/7.3.1/schema_dv_mdb_copies.xml -P /usr/local/solr/solr-7.3.1/server/solr/collection1/conf
wget https://raw.githubusercontent.com/IQSS/dataverse/v4.19/conf/solr/7.3.1/schema_dv_mdb_fields.xml -P /usr/local/solr/solr-7.3.1/server/solr/collection1/conf
wget https://raw.githubusercontent.com/IQSS/dataverse/v4.19/conf/solr/7.3.1/solrconfig.xml -P /usr/local/solr/solr-7.3.1/server/solr/collection1/conf
# ADICIONA USUARIO solr
useradd solr
chown -R solr:solr /usr/local/solr
# REMOVE LIMITS
mv /etc/security/limits.conf /etc/security/limits.conf.bkp
cp $DIR/conf/limits.conf /etc/security/limits.conf
# ATIVA SERVICO SOLR PARA INICIALIZAR COM SISTEMA
mv /usr/lib/systemd/system/solr.service /usr/lib/systemd/system/solr.service.bkp
cp $DIR/service/solr.service /usr/lib/systemd/system/
systemctl daemon-reload
echo "name=collection1" >/usr/local/solr/solr-7.3.1/server/solr/collection1/core.properties
echo "SOLR_LOCATION	localhost:8983" >>$DIR/default.config
echo "TWORAVENS_LOCATION	NOT INSTALLED" >>$DIR/default.config
# START SOLR
echo "Habilitando Solr para iniciar com o sistema!"
systemctl enable solr
echo "Iniciando Solr!"
systemctl start solr
# INICIA COLEÇÃO SOLR
sudo -u solr /usr/local/solr/solr-7.3.1/bin/solr create_core -c collection1 -d /usr/local/solr/solr-7.3.1/server/solr/collection1/conf/
echo "Reiniciando Solr!"
systemctl stop solr
systemctl start solr
# STATUS SERVICE SOLR
systemctl status solr

#!/bin/bash
DIR=$PWD
echo "Parando Postgresql"
systemctl stop postgresql-9.6
echo "Removendo configurações antigas!"
yum remove -y postgresql96-server
yum autoremove -y
TIMESTAMP=$(date "+%Y.%m.%d-%H.%M.%S")
mv /var/lib/pgsql /var/lib/pgsql-$TIMESTAMP
mv /usr/pgsql-9.6 /usr/pgsql-9.6-$TIMESTAMP
# INSTALA DEPENDENCIA POSTGRESQL
echo "Instalando Postgresql!"
yum install -y https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7.1-x86_64/pgdg-redhat-repo-latest.noarch.rpm
yum makecache fast
yum install -y postgresql96-server
# INICIALIZA BANCO DE DADOS POSTGRESQL
/usr/pgsql-9.6/bin/postgresql96-setup initdb
echo "Iniciando Postgresql!"
systemctl start postgresql-9.6
systemctl stop postgresql-9.6
# CONFIGURA POSTGRESQL PARA LIBERAR ACESSO AO BANCO
mv /var/lib/pgsql/9.6/data/pg_hba.conf /var/lib/pgsql/9.6/data/pg_hba.conf.bkp
cp $DIR/conf/pg_hba_trust.conf /var/lib/pgsql/9.6/data/pg_hba.conf
# DEFINE SENHA ADMIN DO POSTGRESQL
echo "Alterando senha root do postgres"
read -p "Password: " PASSWORD
systemctl start postgresql-9.6
psql -U postgres -c "alter user postgres with password '$PASSWORD';"
systemctl stop postgresql-9.6
# CONFIGURA POSTGRESQL PARA LIBERAR ACESSO AO BANCO
rm -rf /var/lib/pgsql/9.6/data/pg_hba.conf
cp $DIR/conf/pg_hba_md5.conf /var/lib/pgsql/9.6/data/pg_hba.conf
echo "POSTGRES_ADMIN_PASSWORD	$PASSWORD" >>$DIR/default.config
echo "POSTGRES_SERVER	localhost" >>$DIR/default.config
echo "POSTGRES_PORT	5432" >>$DIR/default.config
echo "POSTGRES_DATABASE	dvndb" >>$DIR/default.config
echo "POSTGRES_USER	dvnapp" >>$DIR/default.config
echo "POSTGRES_PASSWORD	CREATE_DVNAPP_PASSWORD" >>$DIR/default.config
# START POSTGRES
echo "Habilitando Postgresql para iniciar com o sistema!"
systemctl enable postgresql-9.6
echo "Iniciando Postgresql!"
systemctl start postgresql-9.6
# STATUS DO SERVICO POSTGRES
systemctl status postgresql-9.6
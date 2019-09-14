#!/bin/bash
# INSTALA DEPENDENCIA POSTGRESQL
cd /tmp
rm -rf pgdg-centos96-9.6-3.noarch.rpm
wget https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-x86_64/pgdg-centos96-9.6-3.noarch.rpm
yum install -y pgdg-centos96-9.6-3.noarch.rpm
yum makecache fast
yum install -y postgresql96-server
# INICIALIZA BANCO DE DADOS POSTGRESQL
/usr/pgsql-9.6/bin/postgresql96-setup initdb
/usr/bin/systemctl start postgresql-9.6
/usr/bin/systemctl enable postgresql-9.6
cd /var/lib/pgsql/9.6/data
# CONFIGURA POSTGRESQL PARA LIBERAR ACESSO AO BANCO
rm -f pg_hba.conf
wget https://raw.githubusercontent.com/adornetejr/dataverse-furg/master/pg_hba.conf
systemctl restart postgresql-9.6
# DEFINE SENHA ADMIN DO POSTGRESQL
# su - postgres
# psql
# password 'senha-aqui'
# \q
# exit
# systemctl restart postgresql-9.6
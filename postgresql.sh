#!/bin/bash
DIR=$PWD
# INSTALA DEPENDENCIA POSTGRESQL
cd /tmp
rm -rf pgdg-centos96-9.6-3.noarch.rpm
wget https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-x86_64/pgdg-centos96-9.6-3.noarch.rpm
yum install -y pgdg-centos96-9.6-3.noarch.rpm
yum makecache fast
yum install -y postgresql96-server
# INICIALIZA BANCO DE DADOS POSTGRESQL
/usr/pgsql-9.6/bin/postgresql96-setup initdb
echo "Starting postgresql-9.6!"
systemctl start postgresql-9.6
systemctl enable postgresql-9.6
systemctl stop postgresql-9.6
# CONFIGURA POSTGRESQL PARA LIBERAR ACESSO AO BANCO
cd /var/lib/pgsql/9.6/data
rm -f pg_hba.conf
cp $DIR/pg_hba.conf .
# DEFINE SENHA ADMIN DO POSTGRESQL
echo "Alterando senha root para postgresql"
echo "Digite os comandos:"
echo "# password 'NOVA_SENHA_POSTGRES'"
echo "# \q"
sudo -u postgres psql
systemctl restart postgresql-9.6
systemctl status postgresql-9.6
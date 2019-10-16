#!/bin/bash
DIR=$PWD
yum remove -y postgresql96-server
yum autoremove -y
rm -rf /usr/pgsql-9.6
rm -rf /var/lib/pgsql
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
rm -f /var/lib/pgsql/9.6/data/pg_hba.conf
cp $DIR/pg_hba_trust.conf /var/lib/pgsql/9.6/data/pg_hba.conf
# DEFINE SENHA ADMIN DO POSTGRESQL
echo "Alterando senha root do postgres"
echo "Digite a nova senha:"
read -e $PASSWORD
systemctl start postgresql-9.6
psql -U postgres -c "alter user postgres with password '$PASSWORD';"
systemctl stop postgresql-9.6
# CONFIGURA POSTGRESQL PARA LIBERAR ACESSO AO BANCO
rm -f /var/lib/pgsql/9.6/data/pg_hba.conf
cp $DIR/pg_hba_md5.conf /var/lib/pgsql/9.6/data/pg_hba.conf
systemctl start postgresql-9.6
systemctl status postgresql-9.6
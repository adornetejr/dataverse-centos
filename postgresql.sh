# DEFINE SENHA ADMIN DO POSTGRESQL
su - postgres
psql
password $SENHAPG
\q
exit
systemctl restart postgresql-9.6
#!/bin/bash
DIR=$PWD
systemctl stop sendmail
yum remove -y sendmail sendmail-cf
rm -rf /etc/mail
yum install -y sendmail sendmail-cf m4
# ALTERANDO ARQUIVO HOSTS PARA CONFIGURACAO LOCAL DO SENTMAIL
until $OP != "y"
do
clear
echo "Redes disponiveis"
ip -f inet address
echo "Hostname FQDN"
hostname --fqdn
echo "IP de conexão com a rede externa precisa apontar pra FQDN"
echo "Arquivo hosts:"
cat /etc/hosts
    read -p "Está correto? (y/n): " OP
    if [ "$OP" == "n" ]; then
        echo "Corrija os arquivos /etc/hosts e /etc/hostname"
        echo "Precione Enter após ajustar"
        read -e $X
    else
        break
    fi
done
echo "HOST_DNS_ADDRESS    $HOSTNAME" > $DIR/default.config
# CONFIGURA SENDMAIL
hostname > /etc/mail/local-host-names
hostname > /etc/mail/relay-domains
mv /etc/mail/sendmail.mc /etc/mail/sendmail.mc.1.bkp
sed '/^$/d' $DIR/mail/sendmail.mc
cp $DIR/mail/sendmail.mc /etc/mail/sendmail.mc
m4 /etc/mail/sendmail.mc > /etc/mail/sendmail.cf
systemctl restart sendmail
echo "ADMIN_EMAIL	admin@$HOSTNAME" >> $DIR/default.config
echo "MAIL_SERVER	127.0.0.1" >> $DIR/default.config
echo "Starting sendmail!"
HOST=$(hostname --fqdn)
echo "From: $USER@$HOST" >> $DIR/mail/mail.txt
echo " " >> $DIR/mail/mail.txt
echo "Servidor:" >> $DIR/mail/mail.txt
echo $HOST >> $DIR/mail/mail.txt
echo "Hora:" >> $DIR/mail/mail.txt
TIME=$(date)
echo $TIME >> $DIR/mail/mail.txt
systemctl enable sendmail
systemctl start sendmail
# EMAIL TEST DO SENDMAIL
sendmail -vt < $DIR/mail/mail.txt
# STATUS DO SERVICO SENDMAIL
systemctl status sendmail
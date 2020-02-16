#!/bin/bash
DIR=$PWD
# ALTERANDO ARQUIVO HOSTS PARA CONFIGURACAO LOCAL DO SENTMAIL
until $OP != "Y"
do
    clear
    echo "IP Address"
    ip -f inet address | grep inet
    echo "Hostname"
    echo $HOSTNAME
    read -p "Hostname está correto? (Y/n)" X
    if [ "$OP" != "Y" ]; then
        echo "Corrija os arquivos /etc/hosts e /etc/hostname então!"
        echo "Precione Enter após ajustar"
        read -e $X
    fi
done
echo "HOST_DNS_ADDRESS    $HOSTNAME" > $DIR/default.config
systemctl stop sendmail
yum install -y sendmail sendmail-cf m4
# CONFIGURA SENDMAIL
hostname > /etc/mail/local-host-names
hostname > /etc/mail/relay-domains
rm -f /etc/mail/sendmail.mc
cp $DIR/sendmail.mc /etc/mail/
m4 /etc/mail/sendmail.mc > /etc/mail/sendmail.cf
systemctl restart sendmail
echo "Starting sendmail!"
systemctl enable sendmail
systemctl start sendmail
# STATUS DO SERVICO SENDMAIL
systemctl status sendmail
echo "ADMIN_EMAIL	admin@$HOSTNAME" >> default.config
echo "MAIL_SERVER	127.0.0.1" >> default.config
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
    echo "IP Address"
    ip -f inet address | grep inet
    echo "Hostname FQDN"
    echo $HOSTNAME
    read -p "Hostname está correto? (y/n): " OP
    if [ "$OP" == "n" ]; then
        echo "Corrija os arquivos /etc/hosts e /etc/hostname então!"
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
rm -f /etc/mail/sendmail.mc
cp $DIR/sendmail.mc /etc/mail/
m4 /etc/mail/sendmail.mc > /etc/mail/sendmail.cf
systemctl restart sendmail
echo "ADMIN_EMAIL	admin@$HOSTNAME" >> default.config
echo "MAIL_SERVER	127.0.0.1" >> default.config
echo "Starting sendmail!"
systemctl enable sendmail
systemctl start sendmail
# STATUS DO SERVICO SENDMAIL
systemctl status sendmail
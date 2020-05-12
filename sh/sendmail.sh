#!/bin/bash
DIR=$PWD
echo "Stopping Sendmail!"
systemctl stop sendmail
echo "Removing old settings!"
yum remove -y sendmail sendmail-cf
TIMESTAMP=$(date "+%Y.%m.%d-%H.%M.%S")
mv /etc/mail /etc/mail-$TIMESTAMP
echo "Installing Sendmail!"
yum install -y sendmail sendmail-cf m4
# CHECKING HOST FILE
until $OP != "y"; do
    clear
    echo "Redes disponíveis"
    ip -f inet address
    echo " "
    echo "Domínio FQDN"
    hostname --fqdn
    echo " "
    echo "Arquivo hosts:"
    cat /etc/hosts
    echo " "
    echo "Atenção: IP de conexão com a rede externa precisa apontar pra FQDN"
    echo " "
    read -ep "Configuração está correta? (y/N): " OP
    if [ "$OP" == "n" ]; then
        echo "Corrija os arquivos /etc/hosts e /etc/hostname"
        echo "Precione Enter após ajustar"
        read -e $X
    else
        break
    fi
done
echo "HOST_DNS_ADDRESS    $HOSTNAME" >$DIR/default.config
# SETTING SENDMAIL
echo "Setting up Sendmail!"
hostname >/etc/mail/local-host-names
hostname >/etc/mail/relay-domains
mv /etc/mail/sendmail.mc /etc/mail/sendmail.mc.bkp
HOST=$(hostname --fqdn)
sed "s/dataverse.c3.furg.br/$HOST/g" $DIR/mail/sendmail.config >$DIR/mail/sendmail.mc
cp $DIR/mail/sendmail.mc /etc/mail/sendmail.mc
m4 /etc/mail/sendmail.mc >/etc/mail/sendmail.cf
systemctl restart sendmail
echo "ADMIN_EMAIL	admin@$HOSTNAME" >>$DIR/default.config
echo "MAIL_SERVER	localhost" >>$DIR/default.config
echo "To: ginfo@furg.br" >$DIR/mail/mail.txt
echo "Subject: [Dataverse Script] Test Sendmail">>$DIR/mail/mail.txt
echo "From: $USER@$HOST" >>$DIR/mail/mail.txt
echo " " >>$DIR/mail/mail.txt
echo "Server:" >>$DIR/mail/mail.txt
echo $HOST >>$DIR/mail/mail.txt
echo "Time:" >>$DIR/mail/mail.txt
TIME=$(date)
echo $TIME >>$DIR/mail/mail.txt
# SENDMAIL SYSTEM START
echo "Enabling Sendmail to start with the system!"
systemctl enable sendmail
echo "Starting Sendmail!"
systemctl start sendmail
# SENDMAIL EMAIL TEST
echo "Email test on Sendmail!"
sendmail -vt <$DIR/mail/mail.txt
# SERVICE SENDMAIL STATUS
systemctl status sendmail
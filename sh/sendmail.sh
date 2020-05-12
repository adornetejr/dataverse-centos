#!/bin/bash
DIR=$PWD
echo "Parando Sendmail!"
systemctl stop sendmail
echo "Removendo configurações antigas!"
yum remove -y sendmail sendmail-cf
rm -rf /etc/mail
echo "Instalando Sendmail!"
yum install -y sendmail sendmail-cf m4
# ALTERANDO ARQUIVO HOSTS PARA CONFIGURACAO LOCAL DO SENTMAIL
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
    read -p "Configuração está correta? (y/n): " OP
    if [ "$OP" == "n" ]; then
        echo "Corrija os arquivos /etc/hosts e /etc/hostname"
        echo "Precione Enter após ajustar"
        read -e $X
    else
        break
    fi
done
echo "HOST_DNS_ADDRESS    $HOSTNAME" >$DIR/default.config
# CONFIGURA SENDMAIL
echo "Configurando Sendmail!"
hostname >/etc/mail/local-host-names
hostname >/etc/mail/relay-domains
mv /etc/mail/sendmail.mc /etc/mail/sendmail.mc.bkp
sed '/^$/d' $DIR/mail/sendmail.config >$DIR/mail/sendmail.mc
HOST=$(hostname --fqdn)
sed "s/dataverse.c3.furg.br/$HOST/g" $DIR/mail/sendmail.config >$DIR/mail/sendmail.mc
cp $DIR/mail/sendmail.mc /etc/mail/sendmail.mc
m4 /etc/mail/sendmail.mc >/etc/mail/sendmail.cf
systemctl restart sendmail
echo "ADMIN_EMAIL	admin@$HOSTNAME" >>$DIR/default.config
echo "MAIL_SERVER	127.0.0.1" >>$DIR/default.config
echo "To: ginfo@furg.br" >$DIR/mail/mail.txt
echo "Subject: [Dataverse Script] Test Sendmail">>$DIR/mail/mail.txt
echo "From: $USER@$HOST" >>$DIR/mail/mail.txt
echo " " >>$DIR/mail/mail.txt
echo "Servidor:" >>$DIR/mail/mail.txt
echo $HOST >>$DIR/mail/mail.txt
echo "Hora:" >>$DIR/mail/mail.txt
TIME=$(date)
echo $TIME >>$DIR/mail/mail.txt
# START SENDMAIL
echo "Habilitando Sendmail para iniciar com o sistema!"
systemctl enable sendmail
echo "Iniciando Sendmail!"
systemctl start sendmail
# EMAIL TEST DO SENDMAIL
echo "Teste de email no Sendmail!"
sendmail -vt <$DIR/mail/mail.txt
# STATUS DO SERVICO SENDMAIL
systemctl status sendmail
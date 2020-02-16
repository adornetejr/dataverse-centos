# ALTERANDO ARQUIVO HOSTS PARA CONFIGURACAO LOCAL DO SENTMAIL
echo "IP Address"
ip -f inet address | grep inet
echo "Hostname"
echo $HOSTNAME
echo "HOST_DNS_ADDRESS    $HOSTNAME" > $DIR/default.config
echo "Confira as configurações dos arquivos /etc/hostname e /etc/hosts"
echo "Pressione Enter para continuar!"
read -e $X
# CONFIGURA SENDMAIL
hostname > /etc/mail/local-host-names
hostname > /etc/mail/relay-domains
rm -f /etc/mail/sendmail.mc
cp $DIR/sendmail.mc /etc/mail/
m4 /etc/mail/sendmail.mc > /etc/mail/sendmail.cf
systemctl restart sendmail
echo "ADMIN_EMAIL	admin@$HOSTNAME" >> default.config
echo "MAIL_SERVER	127.0.0.1" >> default.config
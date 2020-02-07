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
hostname > /etc/mail/relay-domains
rm -f /etc/mail/sendmail.mc
cp $DIR/sendmail.mc /etc/mail/
m4 /etc/mail/sendmail.mc > /etc/mail/sendmail.cf
echo "ADMIN_EMAIL	root@$HOSTNAME" >> default.config
echo "MAIL_SERVER	$HOSTNAME" >> default.config
systemctl restart sendmail
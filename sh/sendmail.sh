#!/bin/bash
DIR=$PWD
RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`
echo "${GREEN}Stopping Sendmail!${RESET}"
systemctl stop sendmail
echo "${GREEN}Backing up old installation!${RESET}"
TIMESTAMP=$(date "+%Y.%m.%d-%H.%M.%S")
mv /etc/mail /etc/mail-$TIMESTAMP
echo "${GREEN}Removing old settings!${RESET}"
yum remove -y sendmail sendmail-cf
echo "${GREEN}Installing Sendmail!${RESET}"
yum install -y sendmail sendmail-cf m4
# CHECKING HOST FILE
until [ $OP != "y" ]; do
    clear
    echo "${GREEN}Available networks${RESET}"
    ip -f inet address
    echo " "
    echo "${GREEN}Fully Qualified Domain Name${RESET}"
    hostname --fqdn
    echo " "
    echo "${GREEN}File /etc/hosts:${RESET}"
    cat /etc/hosts
    echo " "
    echo "${RED}Attention: External IP needs to point to FQDN!${RESET}"
    echo " "
    read -ep "Continue? (y/N): " OP
    if [ "$OP" != "y" ]; then
        echo "Correct the files /etc/hosts and /etc/hostname"
        echo "Press Enter after ajust"
        read -e $X
    else
        break
    fi
done
echo "HOST_DNS_ADDRESS    $HOSTNAME" >$DIR/default.config
# SETTING SENDMAIL
echo "${GREEN}Setting up Sendmail!${RESET}"
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
echo "${GREEN}Enabling Sendmail to start with the system!${RESET}"
systemctl enable sendmail
echo "${GREEN}Starting Sendmail!${RESET}"
systemctl start sendmail
# SENDMAIL EMAIL TEST
echo "${GREEN}Email test on Sendmail!${RESET}"
sendmail -vt <$DIR/mail/mail.txt
# SERVICE SENDMAIL STATUS
echo "${GREEN}Sendmail status!${RESET}"
systemctl status sendmail
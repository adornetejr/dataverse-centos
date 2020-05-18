#!/bin/bash
DIR=$PWD
echo "${GREEN}Starting Glassfish!${RESET}"
systemctl start glassfish
echo "${GREEN}Setting up multiple languages support!${RESET}"
curl http://localhost:8080/api/admin/settings/:Languages -X PUT -d '[{"locale":"en","title":"English"},{"locale":"br","title":"Português"}]'
sudo -u glassfish mkdir /home/glassfish/langBundles
echo "${GREEN}Creating languages folder!${RESET}"
echo "/home/glassfish/langBundles"
/usr/local/glassfish4/glassfish/bin/asadmin create-jvm-options '-Ddataverse.lang.directory=/home/glassfish/langBundles'
mkdir /tmp/languages
cd $DIR/lang
cp -R en_US/*.properties /tmp/languages
cp -R pt_BR/*.properties /tmp/languages
cd /tmp/languages
chown glassfish:glassfish *.properties
zip languages.zip *.properties
echo "${GREEN}Uploading languages!${RESET}"
curl http://localhost:8080/api/admin/datasetfield/loadpropertyfiles -X POST --upload-file /tmp/languages/languages.zip -H "Content-Type: application/zip"
echo "${GREEN}Restarting Glassfish!${RESET}"
systemctl restart glassfish
sleep 10
echo " "
echo "${GREEN}Language pt_BR installed!${RESET}"
echo "Stage (10/11) done!"
echo "${RED}Ctrl+C${RESET} to stop or ${GREEN}Enter${RESET} to continue!"
# read -e $X
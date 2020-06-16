#!/bin/bash
DIR=$PWD
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)
echo "${GREEN}Removing old settings!${RESET}"
rm -rf /home/glassfish/langBundles
rm -rf /tmp/languages
echo "${GREEN}Starting Glassfish!${RESET}"
sudo systemctl start glassfish
sleep 10
echo "${GREEN}Downloading submodules!${RESET}"
git submodule init
git submodule update --force
echo "${GREEN}Setting up multiple languages support!${RESET}"
curl http://localhost:8080/api/admin/settings/:Languages -X PUT -d '[{"locale":"en","title":"English"},{"locale":"br","title":"Português"}]'
echo " "
sleep 4
sudo -u glassfish mkdir /home/glassfish/langBundles
echo "${GREEN}Creating languages folder!${RESET}"
echo "/home/glassfish/langBundles"
/usr/local/glassfish4/glassfish/bin/asadmin create-jvm-options '-Ddataverse.lang.directory=/home/glassfish/langBundles'
mkdir /tmp/languages
/bin/cp -Rf $DIR/lang/en_US/*.properties /tmp/languages
/bin/cp -Rf $DIR/lang/pt_BR/*.properties /tmp/languages
cd /tmp/languages
chown glassfish:glassfish *.properties
zip languages.zip *.properties
echo "${GREEN}Uploading languages!${RESET}"
curl http://localhost:8080/api/admin/datasetfield/loadpropertyfiles -X POST --upload-file /tmp/languages/languages.zip -H "Content-Type: application/zip"
echo " "
sleep 4
echo " "
echo "${GREEN}Restarting Glassfish!${RESET}"
sudo systemctl restart glassfish
sleep 10
echo " "
echo "${GREEN}Languages en_US and pt_BR installed!${RESET}"
echo "Stage (11/13) done!"
echo "${RED}Ctrl+C${RESET} to stop or ${GREEN}Enter${RESET} to continue!"
read -e $X
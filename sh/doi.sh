#!/bin/bash
DIR=$PWD
RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`
echo "${GREEN}Starting Glassfish!${RESET}"
sudo systemctl start glassfish
sleep 10
/usr/local/glassfish4/glassfish/bin/asadmin create-jvm-options '-Ddoi.baseurlstring=https\://mds.test.datacite.org'
echo " "
curl -X PUT -d 'doi' localhost:8080/api/admin/settings/:Protocol
echo " "
curl -X PUT -d 'https://mds.test.datacite.org/doi/doi' localhost:8080/api/admin/settings/:doi.baseurlstring
echo " "
echo "${GREEN}Setting up Authority!${RESET}"
# CHANGE AUTHORITY
until [[ ! -z "$AUTHORITY" ]]; do
  echo " "
  echo "${GREEN}Authority is the red part of this example link:${RESET}"
  echo "https://doi.org/${RED}10.7910${RESET}/DVN/OQ64S8/"
  echo " "
  read -ep "New Authority: " AUTHORITY
done
curl -X PUT -d "$AUTHORITY" localhost:8080/api/admin/settings/:Authority
echo " "
echo "${GREEN}Setting up Shoulder!${RESET}"
# CHANGE SHOULDER
until [[ ! -z "$SHOULDER" ]]; do
  echo " "
  echo "${GREEN}Shoulder is the red part of this example link:${RESET}"
  echo "https://doi.org/10.7910/${RED}DVN/${RESET}OQ64S8/"
  echo " "
  read -ep "New Shoulder: " SHOULDER
done
curl -X PUT -d "$SHOULDER" localhost:8080/api/admin/settings/:Shoulder
echo " "
until [[ ! -z "$DOIUSER" ]]; do
  read -ep "${GREEN}DOI User:${RESET} " DOIUSER
  echo " "
done
curl -X PUT -d "$DOIUSER" localhost:8080/api/admin/settings/:doi.username
echo " "
until [[ ! -z "$DOIPASSWORD" ]]; do
  read -ep "${GREEN}DOI Password:${RESET} " DOIPASSWORD
  echo " "
done
curl -X PUT -d "$DOIPASSWORD" localhost:8080/api/admin/settings/:doi.password
echo " "
echo "${GREEN}Restarting Glassfish!${RESET}"
sudo systemctl restart glassfish
echo "${GREEN}Glassfish status!${RESET}"
sudo systemctl status glassfish
echo " "
echo "${GREEN}DOI Configured!${RESET}"
echo "Stage (11/11) done!"
echo "${RED}Ctrl+C${RESET} to stop or ${GREEN}Enter${RESET} to continue!"
read -e $X
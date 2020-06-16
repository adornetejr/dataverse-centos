#!/bin/bash
DIR=$PWD
RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`
echo "${GREEN}Starting Glassfish!${RESET}"
sudo systemctl start glassfish
sleep 10
/usr/local/glassfish4/glassfish/bin/asadmin create-jvm-options '-Ddoi.baseurlstring=https\://mds.test.datacite.org'
curl -X PUT -d 'doi' localhost:8080/api/admin/settings/:Protocol
curl -X PUT -d 'https://mds.test.datacite.org/doi/doi' localhost:8080/api/admin/settings/:doi.baseurlstring
echo "${GREEN}Setting up Authority!${RESET}"
# CHANGE AUTHORITY
until [[ ! -z "$AUTHORITY" ]]; do
  echo "${GREEN}Authority is the red part of this example link:${RESET}"
  echo "https://doi.org/${RED}10.7910${RESET}/DVN/OQ64S8/"
  read -ep "New Authority: " AUTHORITY
done
curl -X PUT -d "$AUTHORITY" localhost:8080/api/admin/settings/:Authority
echo "${GREEN}Setting up Shoulder!${RESET}"
# CHANGE SHOULDER
until [[ ! -z "$SHOULDER" ]]; do
  echo "${GREEN}Shoulder is the red part of this example link:${RESET}"
  echo "https://doi.org/10.7910/${RED}DVN/${RESET}OQ64S8/"
  read -ep "New Shoulder: " SHOULDER
done
curl -X PUT -d "$SHOULDER" localhost:8080/api/admin/settings/:Shoulder
until [[ ! -z "$USER" ]]; do
  read -ep "${GREEN}DOI User:${RESET} " USER
done
curl -X PUT -d "$USER" localhost:8080/api/admin/settings/:doi.username
until [[ ! -z "$PASSWORD" ]]; do
  read -ep "${GREEN}DOI Password:${RESET} " PASSWORD
done
curl -X PUT -d "$PASSWORD" localhost:8080/api/admin/settings/:doi.password
echo "${GREEN}Restarting Glassfish!${RESET}"
sudo systemctl restart glassfish
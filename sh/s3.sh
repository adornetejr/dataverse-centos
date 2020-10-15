#!/bin/bash
DIR=$PWD
RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`
echo "${GREEN}Stopping Payara!${RESET}"
sudo systemctl stop payara.service
echo "${GREEN}Installing AWS CLI!${RESET}"
pip install awscli
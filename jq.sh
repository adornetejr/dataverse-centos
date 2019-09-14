#!/bin/bash
# INSTALA DEPENDENCIA JQ
cd /usr/bin
rm -rf jq
wget http://stedolan.github.io/jq/download/linux64/jq
chmod +x jq
jq --version
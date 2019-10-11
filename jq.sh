#!/bin/bash
# INSTALA DEPENDENCIA JQ
rm -rf /usr/bin/jq
cd /usr/bin
wget http://stedolan.github.io/jq/download/linux64/jq
chmod +x /usr/bin/jq
echo "Checking JQ version!"
jq --version
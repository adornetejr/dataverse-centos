#!/bin/bash
# INSTALA DEPENDENCIA JQ
rm -rf /usr/bin/jq
wget http://stedolan.github.io/jq/download/linux64/jq /usr/bin/
chmod +x /usr/bin/jq
echo "Checking JQ version!"
jq --version
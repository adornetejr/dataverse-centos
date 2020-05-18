#!/bin/bash
DIR=$PWD
systemctl start glassfish
curl http://localhost:8080/api/admin/settings/:Languages -X PUT -d '[{"locale":"en","title":"English"},{"locale":"br","title":"Português"}]'
sudo -u glassfish mkdir /home/glassfish/langBundles
/usr/local/glassfish4/glassfish/bin/asadmin create-jvm-options '-Ddataverse.lang.directory=/home/glassfish/langBundles'
mkdir /tmp/languages
cd $DIR/lang
cp -R en_US/*.properties /tmp/languages
cp -R pt_BR/*.properties /tmp/languages
cd /tmp/languages
chown glassfish:glassfish *.properties
zip languages.zip *.properties
curl http://localhost:8080/api/admin/datasetfield/loadpropertyfiles -X POST --upload-file /tmp/languages/languages.zip -H "Content-Type: application/zip"
systemctl restart glassfish

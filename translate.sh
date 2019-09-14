#!/bin/bash
systemctl stop glassfish.service
cd /usr/local/glassfish4/glassfish/domains/domain1/applications/dataverse/WEB-INF/classes/
rm -rf Bundle.properties
wget https://raw.githubusercontent.com/adornetejr/dataverse-furg/master/Bundle.properties
systemctl start glassfish.service


curl http://localhost:8080/api/admin/settings/:Languages -X PUT -d '[{"locale":"en","title":"English"},{"locale":"pt","title":"Português"}]'

mkdir /home/glassfish/lang
cd /home/glassfish/lang
wget https://raw.githubusercontent.com/adornetejr/dataverse-furg/master/pt_BR.zip

#!/bin/bash
cd
su - glassfish
cd /usr/local/glassfish4/glassfish/domains/domain1/applications/dataverse/WEB-INF/classes/
rm -rf Bundle.properties
wget https://raw.githubusercontent.com/adornetejr/dataverse-furg/master/Bundle.properties
exit
systemctl restart glassfish.service
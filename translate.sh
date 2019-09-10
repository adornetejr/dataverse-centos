#!/bin/bash
systemctl stop glassfish.service
cd /usr/local/glassfish4/glassfish/domains/domain1/applications/dataverse/WEB-INF/classes/
rm -rf Bundle.properties
wget https://raw.githubusercontent.com/adornetejr/dataverse-furg/master/Bundle.properties
systemctl start glassfish.service

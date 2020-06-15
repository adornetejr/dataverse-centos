curl -X PUT -d 'DVN/' localhost:8080/api/admin/settings/:Shoulder
curl -X PUT -d '{USUARIO}' localhost:8080/api/admin/settings/:doi.username
curl -X PUT -d '{SENHA}' localhost:8080/api/admin/settings/:doi.password
curl -X PUT -d '{AUTHORITY}' localhost:8080/api/admin/settings/:Authority
curl -X PUT -d 'doi' localhost:8080/api/admin/settings/:Protocol
curl -X PUT -d 'https://mds.test.datacite.org/doi/doi' localhost:8080/api/admin/settings/:doi.baseurlstring

/usr/local/glassfish4/glassfish/bin/asadmin create-jvm-options '-Ddoi.baseurlstring=https\://mds.test.datacite.org'

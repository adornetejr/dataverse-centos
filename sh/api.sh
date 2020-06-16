#/bin/bash
DIR=$PWD
curl -H X-Dataverse-key:$1 -X POST http://localhost:8080/api/dataverses/root --upload-file $DIR/json/dataverse-complete.json
curl http://localhost:8080/api/dataverses/root

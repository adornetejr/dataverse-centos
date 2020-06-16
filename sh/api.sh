#/bin/bash
DIR=$PWD
echo "Create Dataverse"
curl -H "X-Dataverse-key:$1" -X POST "http://localhost:8080/api/dataverses/root" --upload-file $DIR/json/dataverse-complete.json
echo "Show Dataverse"
curl http://localhost:8080/api/dataverses/root
echo "Create Dataset"
curl -H "X-Dataverse-key:$1" -X POST "http://localhost:8080/api/dataverses/root/datasets" --upload-file "dataset-finch1.json"
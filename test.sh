#!/bin/bash

set -x

docker build -t derkades/cryptclone --no-cache .

sudo rm -rf data-restore data-server data-sync

sudo docker-compose rm -sf
sudo docker-compose up -d server
sudo chown -R 33:33 data-server

mkdir -p data-sync
echo "some test data" > data-sync/test.txt

docker-compose run sync

docker-compose run restore

DATA=`cat data-restore/documents/test.txt 2>/dev/null`

docker-compose rm -sf

sudo rm -rf data-restore data-server data-sync

set +x

if [ "$DATA" == "some test data" ]
then
    echo "Test succeeded"
    exit 0
else
    echo "Test failed"
    exit 1
fi

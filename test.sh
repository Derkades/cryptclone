#!/bin/bash

set -ex

sudo rm -rf data-restore data-server data-sync

sudo docker-compose rm -sf

sudo docker-compose up -d server
sudo chown -R 33:33 data-server

mkdir -p data-sync
echo "some test data" > data-sync/test.txt

docker-compose run sync

docker-compose run restore

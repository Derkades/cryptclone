set -e
docker build -t derkades/cryptclone:latest .
./test.sh
docker push derkades/cryptclone:latest

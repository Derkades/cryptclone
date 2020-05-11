set -e
docker build -t derkades/cryptclone:arm --build-arg RCLONE_TAG=arm .
./test.sh
docker push derkades/cryptclone:arm

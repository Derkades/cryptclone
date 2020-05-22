set -e
./test.sh

export DOCKER_CLI_EXPERIMENTAL=enabled
docker buildx build -t derkades/cryptclone --platform=linux/arm,linux/arm64,linux/amd64 . --push

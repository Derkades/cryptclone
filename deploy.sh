set -e
./test.sh

docker run --rm --privileged docker/binfmt:66f9012c56a8316f9244ffd7622d7c21c1f6f28d
export DOCKER_CLI_EXPERIMENTAL=enabled
set +e
docker buildx rm cryptclone_builder
set -e
docker buildx create --use --name cryptclone_builder
docker buildx build -t derkades/cryptclone --platform=linux/arm,linux/arm64,linux/amd64 . --push
docker buildx rm cryptclone_builder

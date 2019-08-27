#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function get_latest_version() {
    local tag
    tag="$(curl -s -X "GET" "https://api.github.com/repos/gatoreducator/dockagator/tags" | jq -r '.[0].name')"

    if [[ -z "$tag" ]] || [[ "$tag" = "null" ]]; then
        tag="v0.0.0"
    fi

    tag=${tag##v}
    echo "$tag"
    return 0
}

IMAGE_NAME="gatoreducator/dockagator"
TAG="$(get_latest_version)-dev"

NAME="$IMAGE_NAME"
if ! test -z "$TAG"; then
    NAME="$NAME:$TAG"
fi

if [[ "$1" == "clean" ]]; then
    docker image rm --force "$NAME"
    docker image rm --force "$IMAGE_NAME:latest"
fi

docker build -t "$NAME" .
docker build -t "$IMAGE_NAME:latest" .


# Running
# docker stop "dockagator"
# docker rm "dockagator"
#
# docker run --rm --name "dockagator" \
#   --mount "type=bind,source=$DATA_FOLDER,target=/data" \
#     "gatoreducator/dockagator:latest"

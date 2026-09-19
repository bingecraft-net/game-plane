#!/usr/bin/env bash
set -euo pipefail

trap 'echo "Error on line $LINENO"; exit 1' ERR

podman build -t control-scripts -f .control-scripts/Containerfile .control-scripts

podman run --rm \
    --privileged \
    --volume /dev:/dev \
    --volume /run:/run \
    --volume $HOME/.local/share/containers:/root/.local/share/containers \
    --env KIND_EXPERIMENTAL_PROVIDER=podman \
    --env STORAGE_DRIVER=overlay \
    control-scripts \
    idpbuilder create --name "game-plane"
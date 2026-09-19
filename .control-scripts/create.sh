#!/usr/bin/env bash

podman build -t control-scripts -f .control-scripts/Containerfile .control-scripts

podman run --rm control-scripts \
    podman system connection list

podman run --rm control-scripts \
    idpbuilder create --name "game-plane"
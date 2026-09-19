#!/usr/bin/env bash
set -euo pipefail

trap 'echo "Error on line $LINENO"; exit 1' ERR

podman build -t control-scripts -f .control-scripts/Containerfile .control-scripts

podman run --rm control-scripts -- idpbuilder create --name "game-plane"
#!/usr/bin/env bash
set -euo pipefail

trap 'echo "Error on line $LINENO"; exit 1' ERR

PATH="$PATH:$HOME/.local/bin"

if ! which podman ; then
    echo "podman is not installed. Install it to continue."
    exit 1
fi

if ! which idpbuilder ; then
    echo "idpbuilder is not installed. Install it now? [yN]"
    read -r response
    if [ "$response" = "y" ]; then
        curl -sLo tar.gz https://github.com/cnoe-io/idpbuilder/releases/download/v0.10.2/idpbuilder-linux-amd64.tar.gz
        mkdir -p ~/.local/bin ~/.local/share/idpbuilder
        tar -xzf tar.gz -C ~/.local/share/idpbuilder
        install -m 755 ~/.local/share/idpbuilder/idpbuilder ~/.local/bin/idpbuilder
        rm tar.gz
    fi
fi

idpbuilder create --name game-plane --host game-plane.bingecraft.net
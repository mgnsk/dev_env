#!/bin/bash

createVolume() {
	if ! podman volume ls | awk 'NR!=1 { print $2 }' | grep -q $1; then
		podman volume create $1
	fi
}

createVolume "dev_env_go"
createVolume "dev_env_nvim"

mkdir -p ./code

podman run -it -v ./code:/code -v dev_env_go:/home/$USER/go -v dev_env_nvim:/home/$USER/.config/nvim --rm -h dev_env dev_env /bin/bash


#!/bin/bash

createVolume() {
	if ! docker volume ls | awk 'NR!=1 { print $2 }' | grep -q $1; then
		docker volume create $1
	fi
}

createVolume "dev_env_go"
createVolume "dev_env_nvim"
createVolume "dev_env_rustup"

mkdir -p ./code

docker run \
	-it \
	-h dev_env \
	--mount source=dev_env_go,target=/home/$USER/go \
	--mount source=dev_env_nvim,target=/home/$USER/.config/nvim \
	--mount source=dev_env_rustup,target=/home/$USER/.rustup \
	--mount type=bind,source=$(pwd)/code,target=/code \
	--mount type=bind,source=/home/$USER/.ssh,target=/home/$USER/.ssh \
	--rm \
	dev_env \
	/bin/bash


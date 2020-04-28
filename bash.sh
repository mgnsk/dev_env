#!/bin/bash

createVolume() {
	if ! docker volume ls | awk 'NR!=1 { print $2 }' | grep -q $1; then
		docker volume create $1
	fi
}

createVolume "dev_env_go"
createVolume "dev_env_nvim"

mkdir -p ./code

docker run -it -v "$(pwd)/code:/code" -v "dev_env_go:/home/$USER/go" -v "dev_env_nvim:/home/$USER/.config/nvim" --rm -h dev_env dev_env /bin/bash


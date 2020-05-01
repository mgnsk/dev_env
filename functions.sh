#!/bin/bash

#createVolume() {
# 	if ! docker volume ls | awk 'NR!=1 { print $2 }' | grep -q $1; then
#		docker volume create $1
#	fi
#}

run() {
	docker run \
		-it \
		-m 2G \
		-h dev_env \
		--mount type=bind,source=$(pwd)/code,target=/code \
		--mount type=bind,source=/home/$USER/.ssh,target=/home/$USER/.ssh \
		--rm \
		dev_env \
		"$@"
}


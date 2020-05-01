#!/bin/bash

mkdir -p ./code

docker run \
	-it \
	--memory-swappiness=0 \
	-h "$1" \
	--mount type=bind,source=$(pwd)/code,target=/code \
	--mount type=bind,source=/home/$(id -un)/.ssh,target=/home/$(id -un)/.ssh \
	--rm \
	-m 2G \
	"$1" \
	/bin/bash


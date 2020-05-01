#!/bin/bash

run() {
	docker run \
		-it \
		-m 2G \
		-h $1 \
		--mount type=bind,source=$(pwd)/code,target=/code \
		--mount type=bind,source=/home/$(id -un)/.ssh,target=/home/$(id -un)/.ssh \
		--rm \
		"$@"
}

mkdir -p ./code

run $1 /bin/bash


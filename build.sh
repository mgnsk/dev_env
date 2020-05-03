#!/bin/bash

docker-compose build \
	--build-arg user=$(id -un) \
	--build-arg dot_url=https://github.com/mgnsk/dotfiles.git \
	--build-arg dot_commit=5b09974a2ed1a23c8ce07e21637f107f28581c25


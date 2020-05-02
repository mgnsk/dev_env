#!/bin/bash

docker-compose build \
	--build-arg user=$(id -un) \
	--build-arg dot_url=https://github.com/mgnsk/dotfiles.git \
	--build-arg dot_commit=b13a0fac1340a2a78e2c70a3200b3d70699b21f2


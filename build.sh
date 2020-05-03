#!/bin/bash

docker-compose build \
	--build-arg user=$(id -un) \
	--build-arg dot_url=https://github.com/mgnsk/dotfiles.git \
	--build-arg dot_commit=65a7d62f9f21484352a1bfa8c2d683754d18646f


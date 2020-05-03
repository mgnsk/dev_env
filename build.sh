#!/bin/bash

docker-compose build \
	--build-arg user=$(id -un) \
	--build-arg dot_url=https://github.com/mgnsk/dotfiles.git \
	--build-arg dot_commit=4a1af747e0821d74afc8eb192952c1df5a41ca5f


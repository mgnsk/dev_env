#!/bin/bash

docker-compose build \
	--build-arg user=$(id -un) \
	--build-arg dot_url=https://github.com/mgnsk/dotfiles.git \
	--build-arg dot_commit=45465bece491e854171c09ae70a8a73ca0123909


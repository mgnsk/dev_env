#!/bin/bash

docker-compose build \
	--build-arg user=$USER \
	--build-arg dot_commit=8bca1ebcb9da2ff19ea6d4cde8434b37a1bd6830 \
	dev-env


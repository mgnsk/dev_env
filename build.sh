#!/bin/bash

docker-compose build \
	--build-arg user=$USER \
	--build-arg dot_commit=e15ec0b132a46f24034a23eb06a4aa4e600640a4 \
	--force-rm \
	"$@"


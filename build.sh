#!/bin/bash

docker-compose build \
	--build-arg user=$USER \
	--build-arg dot_commit=6f40358 \
	--force-rm \
	"$@"


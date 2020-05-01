#!/bin/bash

docker-compose build \
	--build-arg user=$USER \
	--build-arg dot_commit=53d338b2b11cf47d0b1dd7fa2f0b15138596c7c1 \
	--force-rm \
	"$@"


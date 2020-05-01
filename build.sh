#!/bin/bash

docker-compose build \
	--build-arg user=$USER \
	--build-arg dot_commit=9d747db1297b4383c4b5cd08fa3b5d9e03c28885 \
	--force-rm \
	"$@"


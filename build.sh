#!/bin/bash

docker-compose build \
	--build-arg user=$USER \
	--build-arg dot_commit=d31b8b93ecb48ef2b5183c284be9a28c668838b0 \
	--force-rm \
	"$@"


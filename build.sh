#!/bin/bash

docker-compose build \
	--build-arg user=$USER \
	--build-arg dot_commit=346068033e39866340b48c8ad164dec3cd300841 \
	dev-env


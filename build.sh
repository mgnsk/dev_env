#!/bin/bash

cd images

docker build \
	--build-arg=user=$USER \
	--build-arg=dot_commit=23fc48c \
	-t dev_env .


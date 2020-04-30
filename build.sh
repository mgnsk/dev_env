#!/bin/bash

cd images

docker build \
	--build-arg=user=$USER \
	--build-arg=dot_commit=f206e22 \
	-t dev_env .


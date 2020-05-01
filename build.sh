#!/bin/bash

cd images

docker build \
	--build-arg=user=$USER \
	--build-arg=dot_commit=5f0ea2616bd35291d8636f8f1381fee4a992a915 \
	-t $1 \
	--target $1 \
	.


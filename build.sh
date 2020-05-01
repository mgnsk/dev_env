#!/bin/bash

cd images

docker build \
	--build-arg=user=$USER \
	--build-arg=dot_commit=da07fa0c43d5cad1b4beca331c11413260f75077 \
	-t dev_env .


#!/bin/bash

podman build --build-arg=user=$(id -un) -t dev_env .


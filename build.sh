#!/bin/bash

podman build --build-arg=user=$USER -t dev_env .


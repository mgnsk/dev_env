#!/bin/bash

docker build --build-arg=user=$USER -t dev_env .


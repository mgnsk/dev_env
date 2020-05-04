#!/bin/bash

set -euo pipefail

export BUILDTAG=$(git log --pretty=format:'%h' -n 1)

docker-compose build \
	--build-arg user=$USER \
	--build-arg dot_url=https://github.com/mgnsk/dotfiles.git \
	--build-arg dot_commit=7194863f7db083cc991c10a2551aa9c4236d6e35

docker image prune -f


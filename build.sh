#!/bin/bash

set -euo pipefail

export BUILDTAG=$(git log --pretty=format:'%h' -n 1)

docker-compose build \
	--build-arg user=$USER \
	--build-arg dot_url=https://github.com/mgnsk/dotfiles.git \
	--build-arg dot_commit=61a1c434a2a1b8907417dfa0c833886a9c11f7fe


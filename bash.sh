#!/bin/bash

set -euo pipefail

# TODO
export BUILDTAG=$(git log --pretty=format:'%h' -n 1)

docker-compose run --rm --service-ports dev-env /bin/bash


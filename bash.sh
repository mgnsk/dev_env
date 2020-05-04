#!/bin/bash

set -euo pipefail

docker-compose run --rm --service-ports dev-env /bin/bash


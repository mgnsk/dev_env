#!/bin/bash

set -euo pipefail

docker push mgnsk/dev-env:$(git log --pretty=format:'%h' -n 1)


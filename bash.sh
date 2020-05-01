#!/bin/bash

mkdir -p ./code

docker-compose run --rm --service-ports dev-env /bin/bash


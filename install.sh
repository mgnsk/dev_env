#!/bin/bash

# nvim is also configured to run both these commands on the first startup
# and exits immediately when everything is installed.
# they are here only for documentation purposes.

docker-compose run --rm dev-env nvim --headless -c 'PlugInstall --sync|qa'

docker-compose run --rm dev-env nvim --headless -c 'CocInstall -sync coc-rls|qa'


#!/bin/bash

# nvim is also configured to run these commands on the first startup.
# they are here only for documentation purposes.

docker-compose run --rm dev-env nvim --headless -c 'PlugInstall --sync|qa'

docker-compose run --rm dev-env nvim --headless -c 'CocInstall -sync coc-rls|qa'


#!/bin/bash
set -eou pipefail

umask 002

earlyoom &> /dev/null &

exec "$@"

#!/bin/bash

set -euo pipefail

curl -sL https://git.io/tusk | bash -s -- -b .direnv/bin latest


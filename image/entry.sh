#!/bin/bash

set -euo pipefail

earlyoom &>/dev/null &

useradd -m -G wheel -s /bin/bash ${user}

echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
echo "Defaults:${user} !authenticate" >> /etc/sudoers 

sh -c "$@"


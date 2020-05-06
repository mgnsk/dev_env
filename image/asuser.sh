#!/bin/bash

set -o pipefail

earlyoom &> /dev/null &

groupadd $GROUP
groupmod -g $GID $GROUP

useradd -r -u $UID -g $GID -s /bin/bash $USER
gpasswd -a $USER wheel
usermod -d /homedir -m $USER

chown -R $USER:$GROUP /homedir/.ssh

# This function prints each argument wrapped in single quotes
# (separated by spaces).  Any single quotes embedded in the
# arguments are escaped.
#
shell_quote() {
    # run in a subshell to protect the caller's environment
    (
        sep=''
        for arg in "$@"; do
            sqesc=$(printf '%s\n' "${arg}" | sed -e "s/'/'\\\\''/g")
            printf '%s' "${sep}'${sqesc}'"
            sep=' '
        done
    )
}

sudo -u $USER -H sh -c "umask 002; $(shell_quote "$@")"


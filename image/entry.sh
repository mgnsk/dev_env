#!/bin/bash

set -euo pipefail

earlyoom &>/dev/null &

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

sh -c "$(shell_quote "$@")"


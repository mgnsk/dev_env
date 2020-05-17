#!/bin/bash

set -o pipefail

earlyoom &> /dev/null &

addgroup -g $GID $GROUP

# In case the group exists.
groupmod -g $GID $GROUP

adduser \
	--disabled-password \
	--gecos "" \
	--home /homedir \
	--ingroup $GROUP \
	--uid $UID \
	$USER

addgroup $USER wheel

echo "Defaults:${USER} !authenticate" >> /etc/sudoers
echo "%${GROUP} ALL=(ALL) ALL" >> /etc/sudoers

install -d -m 0700 -o $USER -g $GROUP /homedir/.ssh

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

sudo -E -u $USER -H sh -c "umask 002; $(shell_quote "$@")"


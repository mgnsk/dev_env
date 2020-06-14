#!/bin/bash

set -euo pipefail

for vol
do
	if ! eval "$CMD volume ls" | awk 'NR!=1 { print $2 }' | grep -q "$vol"; then
		echo "creating volume: $vol"
		eval "$CMD volume create $vol"
	else
		echo "using existing volume: $vol"
	fi
done

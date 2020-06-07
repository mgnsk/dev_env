#!/bin/bash

set -euo pipefail

for vol
do
	if ! docker volume ls | awk 'NR!=1 { print $2 }' | grep -q "$vol"; then
		echo "creating volume: $vol"
		docker volume create "$vol"
	else
		echo "using existing volume: $vol"
	fi
done

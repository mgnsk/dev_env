#!/bin/bash

set -euo pipefail

for vol
do
	if ! podman volume ls | awk 'NR!=1 { print $2 }' | grep -q "$vol"; then
		echo "creating volume: $vol"
		podman volume create $vol
	else
		echo "using existing volume: $vol"
	fi
done

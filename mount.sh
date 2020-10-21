#!/bin/bash

set -e

uid=$1
gid=$2
dir=$3

tmp="$(pwd)/.fuse-$(cat /proc/sys/kernel/random/uuid | cut -c-8)"
lowerdir=${tmp}/lowerdir
workdir=${tmp}/workdir
merged=${tmp}/merged

mkdir -p ${lowerdir} ${workdir} ${merged}

podman unshare fuse-overlayfs -o uidmapping=0:${uid}:1,gidmapping=0:${gid}:1,lowerdir=${lowerdir},upperdir=${dir},workdir=${workdir},noxattrs=1,fsync=1,threaded=1 ${merged}

echo ${tmp}

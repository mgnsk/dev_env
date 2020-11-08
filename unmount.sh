#!/bin/bash

set -e

tmp=$1

fusermount3 -u "${tmp}/merged"
rm -rf "${tmp}"

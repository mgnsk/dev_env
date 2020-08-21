### Immutable development image

[![Build Status](https://travis-ci.com/mgnsk/dev_env.svg?branch=master)](https://travis-ci.com/mgnsk/dev_env)

This image serves the purpose of documenting my default environment.

Dependencies:

* Rootless podman with CGroupsV2.
* `podman-compose`

Build and run:

`$ . .envrc` (or use direnv for automatic env).

`$ ./setup.sh`

`$ tusk build`

`$ tusk bash`
 
 To download/update image instead, run:

`$ tusk clean`

`$ tusk bash`

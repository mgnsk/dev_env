### Immutable development image

[![Build Status](https://travis-ci.com/mgnsk/dev_env.svg?branch=master)](https://travis-ci.com/mgnsk/dev_env)

This image serves the purpose of documenting my default environment.

All plugins and tools are version-locked.

#### Screenshot

Running on Termux:
![Android tablet with Termux running Vim](screenshot2.jpg)

`earlyoom` is started on each bash session.

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

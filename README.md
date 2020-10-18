### Immutable development image

This image serves the purpose of documenting my default environment.

Dependencies:

* Rootless podman with CGroupsV2.
* `tusk` task runner (https://github.com/rliebz/tusk)
* `podman-compose`
* `fuse-overlayfs`

Build and run:

`$ tusk build`

`$ tusk bash`

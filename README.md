### Immutable development image

This image serves the purpose of documenting my default environment. The dotfiles URL and commit are build arguments which accept a repository managed with [chezmoi](https://github.com/twpayne/chezmoi).

Quick run
`$ docker run --rm -it --entrypoint /asuser.sh -e UID=$(id -u) -e USER=$(id -un) -e GID=$(id -g) -e GROUP=$(id -gn) mgnsk/dev-env /bin/bash`

The default entrypoint `/asroot.sh` runs as root.
The `/asuser.sh` entrypoint creates a user and runs as it.

### Bind mount
* `./code:/code`

### Persistent volumes
* `/vol`
* `/homedir/.ssh`

### Go

`earlyoom` is started on each bash session. It terminates `gopls` when memory gets full allowing `coc.nvim` to restart it quickly. `coc.nvim` should sort itself out, the next `gd` or equivalent should automatically trigger a new `gopls` instance. The instance is also shared with `vim-go`. If everything automatic fails, use `:CocRestart`.

It seems that after a while of mindlessly `gd`-ing (goto definition) around in the stdlib (`gopls` may have automatically restarted already), it probably finishes scanning the code and finally stays at a stable memory usage. The `earlyoom` prevents the host system from freezing.

### Tasks

Build and run:

`$ tusk build`

`$ tusk bash`
 

 To download/update image, run:

`$ tusk clean`

`$ tusk bash`

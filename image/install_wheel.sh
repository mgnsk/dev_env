
#!/bin/bash

set -euo pipefail

declare -a dirs=(
	"/homedir/.config/coc"
	"/homedir/.local"
	"/homedir/.local/share/direnv"
	"/homedir/.cache"
)

# Set writable directories for wheel group.
for d in ${dirs[@]}; do
	install -d -m 0755 -o root -g wheel $d
	setfacl -m g:wheel:rwX -R $d 
	chmod g+rws $d
done


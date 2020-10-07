FROM mgnsk/toolbox-base:latest

ARG user
ARG group

COPY --chown=${user}:${group} /dotfiles /homedir

RUN bash ~/setup.sh \
	&& rm -rf ~/.cache \
	&& touch ~/.bash_history \
	# Set up volumes.
	&& mkdir -p \
	~/.cache \
	~/.local/share/nvim \
	~/.config/coc/extensions/coc-clangd-data \
	~/.config/coc/extensions/coc-phpls-data \
	~/.local/share/direnv \
	~/.tmux/resurrect \
	~/.composer \
	~/.npm-global \
	~/go

WORKDIR /code

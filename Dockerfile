FROM mgnsk/toolbox-base:latest

COPY --chown=user:user /dotfiles /homedir

ENV USER=user

USER user

RUN bash ~/setup.sh \
	&& rm -rf ~/.cache \
	&& rm -r /tmp/* \
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

ENTRYPOINT ["/entrypoint.sh"]

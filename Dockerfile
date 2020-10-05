FROM mgnsk/toolbox-base:latest

ARG uid
ARG gid

RUN addgroup --gid ${gid} user \
	&& groupmod -g ${gid} user \
	&& adduser \
	--disabled-password \
	--gecos "" \
	--home /homedir \
	--ingroup user \
	--uid ${uid} \
	user \
	&& rm -rf /root \
	&& ln -s /homedir /root

COPY --chown=user:user /dotfiles /homedir
COPY --from=node:alpine --chown=user:user /usr/local/bin /homedir/.npm-global/bin
COPY --from=node:alpine --chown=user:user /usr/local/lib /homedir/.npm-global/lib
COPY --from=rust:alpine --chown=user:user /usr/local/cargo /homedir/.cargo
COPY --from=rust:alpine --chown=user:user /usr/local/rustup /homedir/.rustup

ENV USER=user \
	PATH=/usr/local/go/bin:/homedir/go/bin:/homedir/.npm-global/bin:/homedir/.cargo/bin:$PATH \
	GOPATH=/homedir/go

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

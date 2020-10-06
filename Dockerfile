FROM mgnsk/toolbox-base:latest

ARG uid
ARG gid
ARG user=user
ARG group=user

RUN addgroup --gid ${gid} ${group} \
	&& adduser \
	--disabled-password \
	--gecos "" \
	--home /homedir \
	--ingroup ${group} \
	--uid ${uid} \
	${user} \
	&& rm -rf /root \
	&& ln -s /homedir /root

COPY --chown=${user}:${group} /dotfiles /homedir
#COPY --from=node:alpine --chown=user:user /usr/local/bin /homedir/.npm-global/bin
#COPY --from=node:alpine --chown=user:user /usr/local/lib /homedir/.npm-global/lib
#COPY --from=rust:alpine --chown=user:user /usr/local/cargo /homedir/.cargo
#COPY --from=rust:alpine --chown=user:user /usr/local/rustup /homedir/.rustup

ENV USER=user

USER user

# TODO install yarn in setup.sh? that would create a dependency loop
RUN npm install -g yarn \
	&& bash -c "source ~/.bashrc && ~/setup.sh" \
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

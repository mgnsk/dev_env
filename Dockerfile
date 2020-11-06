FROM mgnsk/toolbox-base:latest

ARG user
ARG group

USER ${user}

ENV USER=${user}

COPY --chown=${user}:${group} /dotfiles /homedir

RUN bash ~/setup.sh \
	&& rm -rf ~/.cache \
	&& mkdir -p \
	~/.cache \
	~/.local/share/nvim \
	~/.local/share/direnv \
	~/.tmux/resurrect \
	~/.composer \
	~/.npm-global \
	~/go \
	~/.cargo \
	~/.local/bin \
	~/.local/lib \
	&& touch ~/.bash_history

WORKDIR /workspace

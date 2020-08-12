FROM alpine:edge AS build-base

RUN apk update \
	&& apk --no-cache upgrade \
	&& apk --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing add \
	build-base \
	coreutils \
	shadow \
	git


# earlyoom installation.
FROM build-base AS dev-earlyoom

RUN mkdir -p /tmp/earlyoom \
	&& cd /tmp/earlyoom \
	&& git clone --depth 1 https://github.com/rfjakob/earlyoom.git . \
	&& make


# Development image.
FROM build-base AS dev-env

ARG uid
ARG gid

RUN addgroup -g ${gid} user \
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

COPY --from=dev-earlyoom /tmp/earlyoom/earlyoom /usr/bin/earlyoom
COPY --from=node:alpine /opt /opt
COPY --from=node:alpine --chown=user:user /usr/local/bin /homedir/.npm-global/bin
COPY --from=node:alpine --chown=user:user /usr/local/lib /homedir/.npm-global/lib
COPY --from=rust:alpine --chown=user:user /usr/local/cargo /homedir/.cargo
COPY --from=rust:alpine --chown=user:user /usr/local/rustup /homedir/.rustup
COPY ./entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh \
	&& apk --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing add \
	bash \
	ncurses \
	tmux \
	direnv \
	tree \
	most \
	neovim \
	luajit \
	go \
	perl \
	py3-pip \
	python3-dev \
	linux-headers \
	clang-dev \
	ctags \
	fzf \
	ripgrep \
	curl

USER user

ENV PATH=/usr/local/go/bin:/homedir/go/bin:/homedir/.npm-global/bin:/homedir/.cargo/bin:$PATH \
	GOPATH=/homedir/go

ARG dot_url
ARG dot_commit

RUN git clone --separate-git-dir=$HOME/.dotfiles ${dot_url} $HOME/dotfiles-tmp \
    && rm -r ~/dotfiles-tmp/ \
	&& /usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME reset --hard ${dot_commit} \
	&& bash ~/setup.sh \
	&& rm -rf ~/.cache \
	&& rm -r /tmp/* \
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

WORKDIR /mount

ENTRYPOINT ["/entrypoint.sh"]

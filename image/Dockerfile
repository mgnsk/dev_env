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


# Rust installation.
FROM rust:alpine AS dev-rust

RUN rustup component add rls rust-analysis rust-src


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
COPY --from=dev-rust --chown=user:user /usr/local/cargo /homedir/.cargo
COPY --from=dev-rust --chown=user:user /usr/local/rustup /homedir/.rustup
COPY ./entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh \
	&& apk --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing add \
	bash \
	ncurses \
	tmux \
	direnv \
	tree \
	most \
	openssh-client \
	chezmoi \
	neovim \
	luajit \
	go \
	perl \
	php7 \
	php7-iconv \
	php7-json \
	php7-mbstring \
	php7-openssl \
	php7-phar \
	php7-simplexml \
	php7-curl \
	php7-tokenizer \
	php7-dom \
	php7-ctype \
	php7-xml \
	php7-xmlwriter \
	php7-pcntl \
	composer \
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

RUN chezmoi init ${dot_url} \
	&& cd ~/.local/share/chezmoi \
	&& git checkout --quiet ${dot_commit} \
	&& chezmoi apply \
	&& bash ~/setup.sh \
	&& rm -rf ~/.cache \
	&& mkdir -p \
	~/.ssh \
	~/.cache \
	~/.local/share/nvim \
	~/.config/coc/extensions/coc-clangd-data \
	~/.config/coc/extensions/coc-phpls-data \
	~/.local/share/direnv \
	~/.tmux/resurrect

WORKDIR /mount

ENTRYPOINT ["/entrypoint.sh"]

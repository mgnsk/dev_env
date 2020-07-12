FROM alpine:edge AS build-base

RUN apk update \
	&& apk --no-cache upgrade \
	&& apk --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing add \
	build-base \
	coreutils \
	bash \
	shadow \
	git \
	curl


# earlyoom installation.
FROM build-base AS dev-earlyoom

RUN mkdir -p /tmp/earlyoom \
	&& cd /tmp/earlyoom \
	&& git clone --depth 1 https://github.com/rfjakob/earlyoom.git . \
	&& make


# System packages.
FROM build-base AS system-pkgs

RUN apk --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing add \
	ncurses \
	tmux \
	direnv \
	tree \
	most \
	openssh-client \
	chezmoi \
	neovim \
	luajit \
	perl \
	ctags \
	fzf \
	ripgrep


# Rust installation.
FROM rust:alpine AS dev-rust

RUN rustup component add rls rust-analysis rust-src


# Go installation.
FROM golang:alpine AS dev-go


# NodeJS installation.
FROM node:alpine AS dev-node


# Node binaries.
FROM alpine:edge AS node-env

COPY --from=dev-node /usr/local/bin/node /node/bin/node
COPY --from=dev-node /usr/local/lib/node_modules /node/lib/node_modules
RUN ln -s /node/lib/node_modules/npm/bin/npm-cli.js /node/bin/npm \
	&& ln -s /node/lib/node_modules/npm/bin/npx-cli.js /node/bin/npx


# Development image.
FROM system-pkgs AS dev-env

ARG UID
ARG GID
ARG USER
ARG GROUP

RUN addgroup -g ${GID} ${GROUP} \
	&& groupmod -g ${GID} ${GROUP} \
	&& adduser \
	--disabled-password \
	--gecos "" \
	--home /homedir \
	--ingroup ${GROUP} \
	--uid ${UID} \
	${USER}

COPY --from=dev-go /usr/local/go /usr/local/go
COPY --from=dev-earlyoom /tmp/earlyoom/earlyoom /usr/bin/earlyoom
COPY --from=node-env --chown=user:user /node /homedir/.npm-global
COPY --from=dev-rust --chown=user:user /usr/local/cargo /homedir/.cargo
COPY --from=dev-rust --chown=user:user /usr/local/rustup /homedir/.rustup

USER user

RUN chezmoi init --apply https://github.com/mgnsk/dotfiles.git \
	&& . ~/.bashrc \
	&& bash ~/setup.sh \
	&& go clean -modcache

WORKDIR /code

CMD ["earlyoom"]

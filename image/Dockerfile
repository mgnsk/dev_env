FROM alpine:edge AS build-base

RUN apk update \
	&& apk --no-cache upgrade \
	&& apk --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing add \
	build-base \
	coreutils \
	bash \
	sudo \
	git \
	curl \
	&& echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers


# earlyoom installation.
FROM build-base AS dev-earlyoom

RUN mkdir -p /tmp/earlyoom \
	&& cd /tmp/earlyoom \
	&& git clone --depth 1 https://github.com/rfjakob/earlyoom.git . \
	&& make


# System packages.
FROM build-base AS system-pkgs

RUN apk --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing add \
	acl \
	shadow \
	ncurses \
	direnv \
	tree \
	most \
	openssh-client \
	chezmoi \
	tmux \
	vim \
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


# Home directory builder.
FROM build-base AS home-builder

RUN apk --no-cache add chezmoi neovim

COPY --from=dev-go /usr/local/go /usr/local/go
COPY --from=node-env /node /node

ENV GOPATH=/homedir/go \
	PATH=$GOPATH/bin:/usr/local/go/bin:/node/bin:/homedir/.npm-global/bin:$PATH

RUN adduser \
	--disabled-password \
	--gecos "" \
	--home /homedir \
	--ingroup wheel \
	builder

USER builder


# User dotfiles and plugins.
FROM home-builder AS dev-home

ARG dot_commit

RUN chezmoi init https://github.com/mgnsk/dotfiles.git \
	&& cd /homedir/.local/share/chezmoi \
	&& git checkout ${dot_commit} \
	&& chezmoi apply \
	&& cd /homedir \
	&& bash setup.sh \
	&& sudo rm -rf \
	/homedir/go/pkg \
	/homedir/.local/share/nvim \
	&& mkdir -p \
	/homedir/.config/coc \
	/homedir/.local/share/nvim \
	/homedir/.local/share/direnv \
	/homedir/.cache \
	&& chmod -R g+rwXs /homedir


# Development image.
FROM system-pkgs AS dev-env

COPY --from=dev-go /usr/local/go /usr/local/go
COPY --from=dev-earlyoom /tmp/earlyoom/earlyoom /usr/bin/earlyoom
COPY --from=node-env /node /node
COPY --from=dev-rust /usr/local/cargo /cargo
COPY --from=dev-rust /usr/local/rustup /rustup
COPY --from=dev-home --chown=root:wheel /homedir /homedir
COPY ./asuser.sh /asuser.sh

RUN mkdir /code

ENV	RUSTUP_HOME=/rustup \
	CARGO_HOME=/cargo \
	GOPATH=/homedir/go \
	PATH=$GOPATH/bin:/cargo/bin:/usr/local/go/bin:/node/bin:/homedir/.npm-global/bin:/homedir/.vim/plugged/gopher.vim/tools/bin:$PATH

WORKDIR /homedir

# setfacl on runtime.
CMD setfacl -m g:wheel:rwX /code

FROM alpine:edge AS build-base

RUN apk update \
	&& apk --no-cache upgrade \
	&& apk --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing add \
	build-base \
	coreutils \
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
	bash \
	ncurses \
	direnv \
	tree \
	most \
	openssh-client \
	chezmoi \
	vim \
	neovim \
	luajit \
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

RUN chgrp -R wheel /homedir \
	&& chmod -R g+s /homedir \
	&& umask 002; \
	curl -fLo /homedir/.vim/autoload/plug.vim --create-dirs \
	https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
	&& npm config set prefix /homedir/.npm-global \
	&& npm install -g yarn \
	&& chezmoi init https://github.com/mgnsk/dotfiles.git \
	&& cd /homedir/.local/share/chezmoi \
	&& git checkout ${dot_commit} \
	&& chezmoi apply \
	&& cd /homedir \
	&& ln -s /homedir/.vimrc /homedir/.vim/init.vim \
	&& ln -s /homedir/.vim /homedir/.config/nvim \
	&& nvim --headless -u /homedir/.vim/plugins.vim -S /homedir/.vim/plugin.lock -c 'qa' \
	&& nvim --headless -u /homedir/.vim/plugins.vim -c 'call gopher#system#setup()' -c 'qa' \
	&& sudo rm -rf \
	/homedir/go/pkg \
	/homedir/.local/share/nvim \
	&& mkdir -p \
	/homedir/.config/coc \
	/homedir/.local/share/nvim \
	/homedir/.local/share/direnv \
	/homedir/.cache


# Development image.
FROM system-pkgs AS dev-env

COPY --from=dev-go /usr/local/go /usr/local/go
COPY --from=dev-earlyoom /tmp/earlyoom/earlyoom /usr/bin/earlyoom
COPY --from=node-env /node /node
COPY --from=dev-rust /usr/local/cargo /cargo
COPY --from=dev-rust /usr/local/rustup /rustup
COPY --from=dev-home /homedir /homedir
COPY ./asuser.sh /asuser.sh

RUN mkdir /code && setfacl -m g:wheel:rwX /code

ENV RUSTUP_HOME=/rustup \
    CARGO_HOME=/cargo \
	GOPATH=/homedir/go \
	PATH=$GOPATH/bin:/cargo/bin:/usr/local/go/bin:/node/bin:/homedir/.npm-global/bin:/homedir/.vim/plugged/gopher.vim/tools/bin:$PATH

WORKDIR /homedir


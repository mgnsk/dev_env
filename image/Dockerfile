FROM alpine:edge AS build-base

RUN apk update \
	&& apk --no-cache upgrade \
	&& apk --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing add \
	build-base \
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
	acl \
	sudo \
	shadow \
	bash \
	ncurses \
	direnv \
	tree \
	most \
	openssh \
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
RUN ln -s /node/lib/node_modules/npm/bin/npm-cli.js /node/bin/npm
RUN ln -s /node/lib/node_modules/npm/bin/npx-cli.js /node/bin/npx


# User dotfiles and plugins.
FROM build-base AS dev-home

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

# Install vim plug and set up yarn.
RUN curl -fLo /homedir/.vim/autoload/plug.vim --create-dirs \
	https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
	&& npm config set prefix /homedir/.npm-global \
	&& npm install -g yarn

ARG dot_commit

# Install commit-locked vim plugins with go tools as a module.
RUN mkdir -p /homedir/.local/share/chezmoi \
	&& cd /homedir/.local/share/chezmoi \
	&& git clone https://github.com/mgnsk/dotfiles.git . \
	&& git checkout --quiet ${dot_commit} \
	&& chezmoi apply \
	&& rm -rf /homedir/.local/share/chezmoi \
	&& cd /homedir \
	&& ln -s /homedir/.vimrc /homedir/.vim/init.vim \
	&& ln -s /homedir/.vim /homedir/.config/nvim \
	&& nvim --headless -S /homedir/.vim/plugin.lock -c 'qa'


# Development image.
FROM system-pkgs AS dev-env

COPY --from=dev-go /usr/local/go /usr/local/go
COPY --from=dev-earlyoom /tmp/earlyoom/earlyoom /usr/bin/earlyoom
COPY --from=node-env /node /node
COPY --from=dev-rust /usr/local/cargo /cargo
COPY --from=dev-rust /usr/local/rustup /rustup
COPY --from=dev-home --chown=root:wheel /homedir /homedir
COPY ./asuser.sh /asuser.sh

ENV RUSTUP_HOME=/rustup \
    CARGO_HOME=/cargo \
	GOPATH=/homedir/go \
	PATH=$GOPATH/bin:/cargo/bin:/usr/local/go/bin:/node/bin:/homedir/.npm-global/bin:/homedir/.vim/plugged/gopher.vim/tools/bin:$PATH

RUN chmod +x /asuser.sh

WORKDIR /homedir


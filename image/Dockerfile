FROM alpine:edge AS build-base

RUN apk update \
	&& apk --no-cache upgrade \
	&& apk --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing add \
	build-base \
	git \
	curl


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


# earlyoom installation.
FROM build-base AS dev-earlyoom

RUN apk --no-cache add git 

RUN mkdir -p /tmp/earlyoom \
	&& cd /tmp/earlyoom \
	&& git clone --depth 1 https://github.com/rfjakob/earlyoom.git . \
	&& make


# Rust installation.
FROM build-base AS dev-rust

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

RUN source ~/.cargo/env \
	&& rustup component add rls rust-analysis rust-src


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

RUN apk --no-cache add git chezmoi curl neovim

COPY --from=dev-go /usr/local/go /usr/local/go
COPY --from=node-env /node /node

ENV GOPATH=/homedir/go \
	PATH=$GOPATH/bin:/usr/local/go/bin:/node/bin:/homedir/.npm/bin:$PATH

RUN adduser \
	--disabled-password \
	--gecos "" \
	--home /homedir \
	--ingroup wheel \
	builder

USER builder

ARG dot_commit

RUN mkdir -p /homedir/.local/share/chezmoi \
	&& cd /homedir/.local/share/chezmoi \
	&& git clone https://github.com/mgnsk/dotfiles.git . \
	&& git checkout --quiet ${dot_commit} \
	&& chezmoi apply \
	&& rm -rf /homedir/.local/share/chezmoi \
	&& cd /homedir \
	&& curl -fLo /homedir/.vim/autoload/plug.vim --create-dirs \
	https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
	&& npm config set prefix /homedir/.npm \
	&& npm install -g yarn \
	&& ln -s /homedir/.vimrc /homedir/.vim/init.vim \
	&& ln -s /homedir/.vim /homedir/.config/nvim \
	&& nvim --headless -S /homedir/.vim/plugin.lock -c 'qa'


# Development image.
FROM system-pkgs AS dev-env

COPY --from=dev-go /usr/local/go /usr/local/go
COPY --from=dev-earlyoom /tmp/earlyoom/earlyoom /usr/bin/earlyoom
COPY --from=node-env /node /node
COPY --from=dev-rust /homedir/.cargo /cargo
COPY --from=dev-rust /homedir/.rustup /rustup
COPY --from=dev-home --chown=root:wheel /homedir /homedir
COPY ./asuser.sh /asuser.sh

ENV RUSTUP_HOME=/rustup \
    CARGO_HOME=/cargo \
	GOPATH=/homedir/go \
	PATH=$GOPATH/bin:/cargo/bin:/usr/local/go/bin:/node/bin:/homedir/.npm/bin:/homedir/.vim/plugged/gopher.vim/tools/bin:$PATH

RUN chmod +x /asuser.sh \
	# Make accessible to owner only. We set the owner in entrypoint.
	&& install -d -m 0700 -o root -g wheel \
	/homedir/.ssh \
	# For other dirs, use the generic wheel group.
	install -d -m 0755 -o root -g wheel \
	/homedir/.local \
	/homedir/.cache \
	/homedir/.config \
	/homedir/.config/coc \
	/homedir/.local/share/direnv \
	&& setfacl -m g:wheel:rwX -R \
	/homedir/.local \
	/homedir/.cache \
	/homedir/.config/coc \
	# Make all new files created owned by wheel group.
	# The umask 002 set in asuser.sh entrypoint makes
	# sure that new files are group writable.
	&& chmod g+rws /homedir \
	&& npm config set prefix ~/.npm

WORKDIR /homedir


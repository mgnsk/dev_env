FROM alpine:edge AS build-base

RUN apk update \
	&& apk --no-cache upgrade \
	&& apk --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing add \
	build-base \
	git


# earlyoom installation.
FROM build-base AS dev-earlyoom

RUN mkdir -p /tmp/earlyoom \
	&& cd /tmp/earlyoom \
	&& git clone --depth 1 https://github.com/rfjakob/earlyoom.git . \
	&& make


# System packages.
FROM build-base AS system-pkgs

RUN apk --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing add \
	coreutils \
	bash \
	shadow \
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
	ripgrep \
	curl


# Rust installation.
FROM rust:alpine AS dev-rust

RUN rustup component add rls rust-analysis rust-src


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

COPY --from=golang:alpine /usr/local/go /usr/local/go
COPY --from=dev-earlyoom /tmp/earlyoom/earlyoom /usr/bin/earlyoom
COPY --from=node:alpine --chown=user:user /usr/local/bin /homedir/.npm-global/bin
COPY --from=node:alpine --chown=user:user /usr/local/lib /homedir/.npm-global/lib
COPY --from=node:alpine /opt /opt
COPY --from=dev-rust --chown=user:user /usr/local/cargo /homedir/.cargo
COPY --from=dev-rust --chown=user:user /usr/local/rustup /homedir/.rustup

USER user

ENV PATH=/usr/local/go/bin:/homedir/go/bin:/homedir/.npm-global/bin:/homedir/.cargo/bin:$PATH \
	GOPATH=/homedir/go

RUN chezmoi init --apply https://github.com/mgnsk/dotfiles.git \
	&& bash ~/setup.sh \
	&& go clean -modcache

WORKDIR /code

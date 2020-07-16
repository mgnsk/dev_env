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


# Rust installation.
FROM rust:alpine AS dev-rust

RUN rustup component add rls rust-analysis rust-src


# Development image.
FROM build-base AS dev-env

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
	clang-dev \
	ctags \
	fzf \
	ripgrep \
	curl

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
COPY --from=golang:alpine /usr/local/go /usr/local/go
COPY --from=node:alpine /opt /opt
COPY --from=node:alpine --chown=user:user /usr/local/bin /homedir/.npm-global/bin
COPY --from=node:alpine --chown=user:user /usr/local/lib /homedir/.npm-global/lib
COPY --from=dev-rust --chown=user:user /usr/local/cargo /homedir/.cargo
COPY --from=dev-rust --chown=user:user /usr/local/rustup /homedir/.rustup
COPY ./entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

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
	&& go clean -modcache \
	&& mkdir -p \
	/homedir/.ssh \
	/homedir/.config/coc \
	/homedir/.local/share/nvim \
	/homedir/.local/share/direnv \
	/homedir/.tmux/resurrect

WORKDIR /mount

ENTRYPOINT ["/entrypoint.sh"]

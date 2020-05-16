# Base system.
FROM alpine:edge AS system-base

RUN apk update \
	&& apk --no-cache upgrade \
	&& apk --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing add \
	build-base \
	acl \
	sudo \
	bash \
	curl \
	direnv \
	git \
	tree \
	most \
	openssh \
	chezmoi \
	vim \
	neovim \
	luajit \
	nodejs \
	npm \
	yarn \
	ctags \
	fzf \
	ripgrep


# Set up build user.
FROM system-base AS build-user

RUN adduser \
    --disabled-password \
    --gecos "" \
    --home /homedir \
    --ingroup wheel \
    builder \
	&& echo "Defaults:builder !authenticate" >> /etc/sudoers \
	&& echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

USER builder


# Rust installation.
FROM build-user AS dev-rust

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

RUN source ~/.cargo/env \
	&& rustup component add rls rust-analysis rust-src


# earlyoom installation.
FROM build-user AS dev-earlyoom

RUN mkdir -p /tmp/earlyoom \
	&& cd /tmp/earlyoom \
	&& git clone --depth 1 https://github.com/rfjakob/earlyoom.git . \
	&& make


# User dotfiles and plugins.
FROM build-user AS dev-home

COPY --from=golang:alpine /usr/local/go /usr/local/go

ARG dot_url

ARG dot_commit

ENV GOPATH=/homedir/go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p ~/.local/share/chezmoi \
	&& cd ~/.local/share/chezmoi \
	&& git clone ${dot_url} . \
	&& git checkout --quiet ${dot_commit} \
	&& chezmoi apply \
	&& rm -rf ~/.local/share/chezmoi \
	&& cd ~ \
	&& curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
	https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
	&& nvim --headless -S ~/.config/nvim/plugin.lock -c 'qa' \
	&& sudo rm -rf ~/go/pkg


# Development image.
FROM system-base AS dev-env

COPY --from=golang:alpine /usr/local/go /usr/local/go
COPY --from=dev-earlyoom /tmp/earlyoom/earlyoom /usr/bin/earlyoom
COPY --from=dev-home --chown=root:wheel /homedir /homedir
COPY --from=dev-rust /homedir/.cargo /homedir/.cargo
COPY --from=dev-rust /homedir/.rustup /homedir/.rustup
COPY ./asuser.sh /asuser.sh

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
	/homedir/.config \
	# Make all new files created owned by wheel group.
	# The umask 002 set in asuser.sh entrypoint makes
	# sure that new files are group writable.
	&& chmod g+rws /homedir

ENV GOPATH=/homedir/go \
	PATH=$GOPATH/bin:/usr/local/go/bin:/homedir/.cargo/bin:$PATH

WORKDIR /homedir


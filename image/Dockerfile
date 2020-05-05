# Base system.
FROM archlinux AS system-base

RUN pacman-key --init \
	&& pacman-key --populate archlinux \
	&& pacman -Syu --noconfirm

RUN pacman -S --needed --noconfirm \
	base-devel \
	earlyoom \
	chezmoi \
	git \
	vim \
	neovim \
	go \
	rustup \
	&& rm -rf /var/cache/pacman/pkg


# Dev packages.
FROM system-base AS dev-base

RUN pacman -S --needed --noconfirm \
	ctags \
	fzf \
	ripgrep \
	python \
	nodejs \
	npm \
	&& rm -rf /var/cache/pacman/pkg


# Add the builder user.
FROM system-base as builder-user

RUN useradd -m -G wheel -s /bin/bash builder \
	&& usermod -d /homedir -m builder \
	&& echo "Defaults:builder !authenticate" >> /etc/sudoers \
	&& echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers


# Direnv installation.
FROM builder-user AS direnv

USER builder

RUN mkdir -p /tmp/direnv \
	&& cd /tmp/direnv \
	&& git clone https://aur.archlinux.org/direnv.git . \
	&& makepkg -si --noconfirm


# Rust installation.
FROM builder-user AS rust

USER builder

RUN rustup self upgrade-data \
	&& rustup update stable \
	&& rustup component add rls rust-analysis rust-src


# User configuration.
FROM builder-user AS dev-home

ARG dot_url

ARG dot_commit

USER builder

RUN mkdir -p ~/.local/share/chezmoi \
	&& cd ~/.local/share/chezmoi \ 
	&& git clone ${dot_url} . \
	&& git checkout --quiet ${dot_commit} \
	&& chezmoi apply \
	&& rm -rf ~/.local/share/chezmoi \
	&& curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
	&& cd ~ \
	&& nvim --headless -c 'PlugInstall --sync|qa' \
	&& nvim --headless -c 'CocInstall -sync coc-rls|qa'


# Development image.
FROM dev-base AS dev-env

COPY --from=dev-home --chown=root:wheel /homedir /homedir
COPY --from=rust --chown=root:wheel /homedir/.rustup /homedir/.rustup
COPY --from=direnv /usr/bin/direnv /usr/bin/direnv
COPY ./entry.sh /entry
COPY ./asuser.sh /asuser

RUN chmod +x /entry /asuser \
	&& mkdir -p /code \
	&& setfacl -m g:wheel:rw -R /homedir

WORKDIR /code

ENTRYPOINT ["/entry"]


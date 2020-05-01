# Base system.
FROM archlinux AS system-base

RUN pacman-key --init \
	&& pacman-key --populate archlinux \
	&& pacman -Syu --noconfirm \
	&& pacman -S --noconfirm base-devel

RUN pacman -S --noconfirm \
	git \
	openssh \
	neovim \
	go \
	rustup \
	&& bash -c "yes | pacman -Scc"

ARG user

RUN useradd -m ${user} && usermod -aG wheel ${user} \
	&& echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers \
	&& echo "Defaults:${user} !authenticate" >> /etc/sudoers \
	&& mkdir /code \
	&& chown -R ${user}:${user} /code \
	&& mkdir -p /home/${user}/go \
	&& chown -R ${user}:${user} /home/${user}/go

USER ${user}

ENV USER=${user}


# Rust installation.
FROM system-base AS rust

RUN rustup self upgrade-data \
	&& rustup update stable \
	&& rustup component add rls rust-analysis rust-src


# Direnv installation.
FROM system-base as direnv

RUN mkdir -p /tmp/direnv \
	&& cd /tmp/direnv \
	&& git clone https://aur.archlinux.org/direnv.git . \
	&& makepkg -si --noconfirm


# System packages.
FROM system-base AS dev-pkgs

RUN sudo pacman -S --noconfirm \
	chezmoi \
	ctags \
	fzf \
	ripgrep \
	python \
	nodejs \
	npm \
	&& bash -c "yes | sudo pacman -Scc"


# Development image.
FROM dev-pkgs as dev-env

ARG user

COPY --from=rust /home/${user}/.rustup /home/${user}/.rustup

COPY --from=direnv /usr/bin/direnv /usr/bin/direnv

ARG dot_commit

RUN mkdir -p ~/.local/share/chezmoi \
	&& cd ~/.local/share/chezmoi \ 
	&& git clone https://github.com/mgnsk/dotfiles.git . \
	&& git checkout ${dot_commit} \
	&& chezmoi apply \
	&& rm -rf ~/.local/share/chezmoi

ENV USER ${user}

SHELL ["/bin/bash"]

WORKDIR /code


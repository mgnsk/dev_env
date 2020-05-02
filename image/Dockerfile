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
	go \
	rustup \
	&& rm -rf /var/cache/pacman/pkg

ARG user

RUN useradd -m -G wheel -s /bin/bash ${user} \
	&& echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers \
	&& echo "Defaults:${user} !authenticate" >> /etc/sudoers


# Direnv installation.
FROM system-base AS direnv

ARG user

USER ${user}

RUN mkdir -p /tmp/direnv \
	&& cd /tmp/direnv \
	&& git clone https://aur.archlinux.org/direnv.git . \
	&& makepkg -si --noconfirm


# User packages.
FROM system-base AS dev-pkgs

RUN pacman -S --needed --noconfirm \
	neovim \
	ctags \
	fzf \
	ripgrep \
	python \
	nodejs \
	npm \
	&& rm -rf /var/cache/pacman/pkg


# Rust installation.
FROM system-base AS rust

ARG user

USER ${user}

RUN rustup self upgrade-data \
	&& rustup update stable \
	&& rustup component add rls rust-analysis rust-src


# User configuration.
FROM system-base AS dev-home

ARG user

ARG dot_url

ARG dot_commit

USER ${user}

RUN mkdir -p ~/.local/share/chezmoi \
	&& cd ~/.local/share/chezmoi \ 
	&& git clone ${dot_url} . \
	&& git checkout ${dot_commit} \
	&& chezmoi apply \
	&& rm -rf ~/.local/share/chezmoi \
	&& mkdir -p ~/go ~/code


# Development image.
FROM dev-pkgs AS dev-env

ARG user

COPY --from=dev-home /home/${user} /home/${user}
COPY --from=rust --chown=${user}:${user} /home/${user}/.rustup /home/${user}/.rustup
COPY --from=direnv /usr/bin/direnv /usr/bin/direnv
COPY ./entry.sh /entry.sh

ENV USER ${user}

USER ${user}

WORKDIR /home/${user}/code

ENTRYPOINT ["/entry.sh"]


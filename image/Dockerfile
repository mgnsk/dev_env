# Base system.
FROM archlinux AS system-base

RUN pacman-key --init \
	&& pacman-key --populate archlinux \
	&& pacman -Syu --noconfirm

# Install manually instead of base-devel.
RUN pacman -S --needed --noconfirm \
	sudo \
	fakeroot \
	binutils \
	make \
	git \
	go \
	rustup \
	&& rm -rf /var/cache/pacman/pkg


# Add the builder user.
FROM system-base as builder-user

RUN useradd -m -G wheel -s /bin/bash builder \
	&& usermod -d /homedir -m builder \
	&& echo "Defaults:builder !authenticate" >> /etc/sudoers \
	&& echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

USER builder


# Direnv installation.
FROM builder-user AS direnv

RUN mkdir -p /tmp/direnv \
	&& cd /tmp/direnv \
	&& git clone --depth 1 https://aur.archlinux.org/direnv.git . \
	&& makepkg -si --noconfirm


# Rust installation.
FROM builder-user AS rust

RUN rustup self upgrade-data \
	&& rustup update stable \
	&& rustup component add rls rust-analysis rust-src


# Development packages
FROM system-base AS dev-pkgs

RUN pacman -S --needed --noconfirm \
	tree \
	most \
	openssh \
	earlyoom \
	chezmoi \
	vim \
	neovim \
	nodejs \
	npm \
	yarn \
	ctags \
	fzf \
	ripgrep \
	&& rm -rf /var/cache/pacman/pkg


# User configuration.
FROM builder-user AS dev-home

ARG dot_url

ARG dot_commit

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
FROM dev-pkgs AS dev-env

COPY --from=direnv /usr/bin/direnv /usr/bin/direnv
COPY --from=dev-home --chown=root:wheel /homedir /homedir
COPY --from=rust --chown=root:wheel /homedir/.rustup /homedir/.rustup
COPY ./asroot.sh /asroot.sh
COPY ./asuser.sh /asuser.sh

RUN chmod +x /asroot.sh /asuser.sh \
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

WORKDIR /homedir

ENTRYPOINT ["/asroot.sh"]


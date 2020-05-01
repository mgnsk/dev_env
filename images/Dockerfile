# Base system.
FROM archlinux AS system-base

RUN pacman-key --init \
	&& pacman-key --populate archlinux \
	&& pacman -Syu --noconfirm \
	&& pacman -S --noconfirm base-devel \
	&& bash -c "yes | pacman -Scc"

# User base system.
FROM system-base AS user-base

ARG user

RUN useradd -m ${user} && usermod -aG wheel ${user} \
	&& echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers \
	&& echo "Defaults:${user} !authenticate" >> /etc/sudoers \
	&& mkdir /code \
	&& chown -R ${user}:${user} /code \
	&& mkdir -p /home/${user}/go \
	&& chown -R ${user}:${user} /home/${user}/go

RUN pacman -S --noconfirm \ 
	openssh \
	neovim \
	git \
	ctags \
	fzf \
	ripgrep \
	chezmoi \
	go \
	python \
	nodejs \
	npm \
	rustup

RUN bash -c "yes | pacman -Scc"

USER ${user}


# Rust.
FROM user-base AS rust

RUN rustup self upgrade-data \
	&& rustup update stable \
	&& rustup component add rls rust-analysis rust-src


# Direnv.
FROM user-base as direnv

RUN mkdir -p /tmp/direnv \
	&& cd /tmp/direnv \
	&& git clone https://aur.archlinux.org/direnv.git . \
	&& makepkg -si --noconfirm


# Dotfiles and plugins.
FROM user-base AS homedir

RUN mkdir -p ~/.local/share/chezmoi \
	&& cd ~/.local/share/chezmoi \ 
	&& git clone https://github.com/mgnsk/dotfiles.git . \
	&& git checkout ${dot_commit} \
	&& chezmoi apply \
	&& rm -rf ~/.local/share/chezmoi

# Install vim-plug.
RUN curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
	https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install go toolchain.
RUN nvim --headless -c 'PlugInstall --sync|qa' \
	# Install rust language server plugin.
	&& nvim --headless -c 'CocInstall -sync coc-rls|qa'


# The final image.
FROM archlinux as dev-env

ARG user

COPY --from=user-base / /
COPY --from=homedir /home /home
COPY --from=direnv /usr/bin/direnv /usr/bin/direnv
COPY --from=rust /home/${user}/.rustup /home/${user}/.rustup

USER ${user}

ENV USER=${user}

SHELL ["/bin/bash"]

WORKDIR /code


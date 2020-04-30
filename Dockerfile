FROM archlinux

RUN pacman-key --init \
	&& pacman-key --populate archlinux \
	&& pacman -Syu --noconfirm \
	&& pacman -S --noconfirm \
	base-devel \
	openssh \
	git

RUN pacman -S --noconfirm \
	ctags \
	chezmoi \
	go \
	rustup \
	nodejs \
	npm \
	neovim

ARG user

RUN useradd -m ${user} && usermod -aG wheel ${user} \
	&& echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers \
	&& echo "Defaults:${user} !authenticate" >> /etc/sudoers \
	&& mkdir /code \
	&& chown -R ${user}:${user} /code \
	&& mkdir -p /home/${user}/go \
	&& chown -R ${user}:${user} /home/${user}/go

USER $user

RUN rustup self upgrade-data \
	&& rustup update stable

RUN mkdir -p /tmp/direnv \
	&& cd /tmp/direnv \
	&& git clone https://aur.archlinux.org/direnv.git . \
	&& makepkg -si --noconfirm

RUN mkdir -p ~/.local/share/chezmoi \
	&& cd ~/.local/share/chezmoi \ 
	&& git clone https://github.com/mgnsk/dotfiles.git . \
	&& git checkout 576c122 \
	&& chezmoi apply

RUN curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
	https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# This installs the go toolchain.
RUN nvim --headless -c 'PlugInstall --sync|qa'

# When opening a cargo project, the plugin will ask to install rls toolchain.
RUN nvim --headless -c 'CocInstall -sync coc-rls|qa'

ENV USER=${user}

WORKDIR /code


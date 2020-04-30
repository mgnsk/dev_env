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
	fzf \
	ripgrep \
	chezmoi \
	go \
	rustup \
	python \
	nodejs \
	npm \
	neovim

RUN bash -c "yes | pacman -Scc"

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
	&& rustup update stable \
	&& rustup component add rls rust-analysis rust-src

RUN mkdir -p /tmp/direnv \
	&& cd /tmp/direnv \
	&& git clone https://aur.archlinux.org/direnv.git . \
	&& makepkg -si --noconfirm

ARG dot_commit

RUN mkdir -p ~/.local/share/chezmoi \
	&& cd ~/.local/share/chezmoi \ 
	&& git clone https://github.com/mgnsk/dotfiles.git . \
	&& git checkout ${dot_commit} \
	&& chezmoi apply \
	&& rm -rf ~/.local/share/chezmoi

RUN curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
	https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install go toolchain.
RUN nvim --headless -c 'PlugInstall --sync|qa' \
	# Install rust language server plugin.
	&& nvim --headless -c 'CocInstall -sync coc-rls|qa'

ENV USER=${user}

SHELL ["/bin/bash"]

WORKDIR /code


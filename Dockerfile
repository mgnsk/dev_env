FROM archlinux

ARG user

ENV USER=${user}

RUN pacman-key --init \
	&& pacman-key --populate archlinux \
	&& pacman -Syu --noconfirm \
	&& pacman -S --noconfirm \
	base-devel \
	ctags \
	chezmoi \
	go \
	rust \
	nodejs \
	npm \
	git \
	openssh \
	neovim

RUN useradd -m ${user} && usermod -aG wheel ${user} \
	&& echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers \
	&& echo "Defaults:${user} !authenticate" >> /etc/sudoers \
	&& mkdir /code \
	&& chown -R ${user}:${user} /code \
	&& mkdir -p /home/${user}/go \
	&& chown -R ${user}:${user} /home/${user}/go

USER $user

RUN mkdir -p /tmp/direnv \
	&& cd /tmp/direnv \
	&& git clone https://aur.archlinux.org/direnv.git . \
	&& makepkg -si --noconfirm

RUN mkdir -p ~/.local/share/chezmoi \
	&& cd ~/.local/share/chezmoi \ 
	&& git clone https://github.com/mgnsk/dotfiles.git . \
	&& git checkout 831d97d \
	&& chezmoi apply

WORKDIR /code


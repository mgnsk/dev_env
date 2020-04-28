FROM archlinux

ARG user

RUN pacman-key --init \
	&& pacman-key --populate archlinux \
	&& pacman -Syu --noconfirm \
	&& pacman -S --noconfirm \
	base-devel \
	ctags \
	chezmoi \
	go \
	nodejs \
	npm \
	git \
	neovim

RUN useradd -m ${user} && usermod -aG wheel ${user} \
	&& echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers \
	&& echo "Defaults:${user} !authenticate" >> /etc/sudoers \
	&& mkdir /code \
	&& chown -R ${user}:${user} /code

USER $user

RUN mkdir -p /tmp/direnv \
	&& cd /tmp/direnv \
	&& git clone https://aur.archlinux.org/direnv.git . \
	&& makepkg -si --noconfirm

RUN mkdir -p ~/.local/share/chezmoi \
	&& cd ~/.local/share/chezmoi \ 
	&& git clone --depth 1 https://github.com/mgnsk/dotfiles.git . \
	&& chezmoi apply

WORKDIR /code


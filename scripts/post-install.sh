#!/bin/env sh

sed '/Color/ s/^#//' -i /etc/pacman.conf

#pacman -R iptables -dd
#pacman -S --noconfirm --needed lxd

#pacman -S --noconfirm --needed \
#	base-devel \
#	git \
#	neovim emacs-nox \
#	zsh starship \
#	tmux zellij \
#	exa bat \
#	fd skim ripgrep-all \
#	procs \
#	lsd sd dust bottom tldr zoxide hyperfine grex bandwhich nushell mcfly pueue watchexec broot duf \
#	gtop \
#	jq \
#	helm buildah podman cri-o minikube kubectl \
#	autossh sshfs \
#	ranger \
#	hugo man xplr \
#	cri-o kubeadm docker vagrant libvirt sshpass expect \
#	lazygit

pacman -S --noconfirm --needed sudo

cat <<EOF | tee /etc/sudoers.d/custom
%adm ALL=(ALL) NOPASSWD: ALL
Defaults umask_override
Defaults umask=0022
EOF

useradd -G adm -l -m -p `openssl passwd -1 judeops` jude

mkdir -m 700 ~jude/.ssh

touch ~jude/.ssh/authorized_keys
chmod og-r $_

chown -R jude:jude ~jude/.ssh

#ssh-keygen -f ~/.ssh/jude-key-ecdsa -t ecdsa -b 521 -N '' -C 'lliujinjun@163.com'
echo 'ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBABZgSwWSldSc22UrMAhX5r3kiAGHQ7KjqTP5R3S7J7+XVAFUHL/udGDtkgnhd8LPyXM6pfm7p/TiX06hzRG526J1ABuYsH1uTqu9AuscI2x/BquvOom8KYB6yHVYjL3PDZpfYLwjPIxEEWMlAwaNTOU4CPPgcgb+nQwjMKTymxDox+ctg== lliujinjun@163.com' >> ~jude/.ssh/authorized_keys

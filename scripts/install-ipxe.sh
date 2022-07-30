#!/bin/env sh
IPADDRESS=$(ip a | awk '/inet / && !/ lo/ {gsub("/24", ""); print substr($2, 1)}')

sudo sed -i "s@http://.*archive.ubuntu.com@http://repo.huaweicloud.com@g" /etc/apt/sources.list
sudo sed -i "s@http://.*security.ubuntu.com@http://repo.huaweicloud.com@g" /etc/apt/sources.list

sudo apt-get update
sudo apt-get install liblzma-dev -y

sudo apt-get install dnsmasq git build-essential -y

sudo mkdir -p /home/tftp/ipxe
cat <<EOF | sudo tee /home/tftp/embed.ipxe
#!ipxe
dhcp && goto netboot || goto dhcperror

:dhcperror
prompt --key s --timeout 10000 DHCP failed, hit 's' for the iPXE shell; reboot in 10 seconds && shell || reboot

:netboot
chain tftp://$IPADDRESS/default.ipxe ||
prompt --key s --timeout 10000 Chainloading failed, hit 's' for the iPXE shell; reboot in 10 seconds && shell || reboot
EOF

git clone https://github.com/ipxe/ipxe
cd ipxe/src
make bin-x86_64-efi/snponly.efi EMBED=/home/tftp/embed.ipxe
make bin/undionly.kpxe EMBED=/home/tftp/embed.ipxe
sudo cp bin-x86_64-efi/snponly.efi /home/tftp/ipxe/
sudo cp bin/undionly.kpxe /home/tftp/ipxe/

cat <<'EOF' | sudo tee /home/tftp/default.ipxe
#!ipxe
:MENU
menu
item --gap -- ---------------- iPXE boot menu ----------------
item archlinux Archlinux
item hello        Hello world
item shell          ipxe shell
choose --default return --timeout 5000 target && goto ${target}

:archlinux
chain tftp://$IPADDRESS/archlinux.ipxe

:hello
echo "hello world"
boot ||
goto MENU

:shell
shell ||
goto MENU

autoboot
EOF

cat <<EOF | sudo tee /etc/dnsmasq.d/custom
interface=eth0
bind-dynamic
dhcp-range=$IPADDRESS,proxy
enable-tftp
tftp-root=/home/tftp
pxe-service=x86PC, "ipxe bios", ipxe/undionly.kpxe
pxe-service=x86-64_efi, "ipxe efi", ipxe/snponly.efi
EOF

sudo systemctl restart dnsmasq

sudo sed 's|$IPADDRESS|'"$IPADDRESS"'|' -i /home/tftp/default.ipxe

cat <<'EOF' | sudo tee /home/tftp/archlinux.ipxe
#!ipxe

set mirrorurl http://mirrors.163.com/archlinux/
set release latest
set extrabootoptions ip=dhcp net.ifnames=0 BOOTIF=01-${netX/mac} script=https://raw.githubusercontent.com/lliujinjun/ipxe-automate/main/scripts/install-archops.sh

EOF

curl https://ipxe.archlinux.org/releng/netboot/archlinux.ipxe | sed -n '1715,1724p' | sed 's/ ||.*$//; /imgverify/d; s/verify=y/verify=n/' | sudo tee -a /home/tftp/archlinux.ipxe

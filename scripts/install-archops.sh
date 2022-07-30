#!/bin/env sh
set -x

echo "label: gpt" | sfdisk /dev/sda
echo -e 'size=512M, type=U\n size=500G, type=L\n size=+, type=S\n' | sfdisk /dev/sda

mkfs.vfat -F32 -n EFI /dev/sda1
mkfs.btrfs -L ROOT /dev/sda2
mkswap -L SWAP /dev/sda3
swapon /dev/sda3

mount /dev/sda2 /mnt
btrfs sub create /mnt/@
btrfs sub create /mnt/@home
btrfs sub create /mnt/@pkg
btrfs sub create /mnt/@snapshots
umount /mnt

mount -o noatime,nodiratime,compress=zstd,space_cache=v2,ssd,subvol=@ /dev/sda2 /mnt
mkdir -p /mnt/{boot,home,var/cache/pacman/pkg,.snapshots,btrfs}
mount -o noatime,nodiratime,compress=zstd,space_cache=v2,ssd,subvol=@home /dev/sda2 /mnt/home
mount -o noatime,nodiratime,compress=zstd,space_cache=v2,ssd,subvol=@pkg /dev/sda2 /mnt/var/cache/pacman/pkg
mount -o noatime,nodiratime,compress=zstd,space_cache=v2,ssd,subvol=@snapshots /dev/sda2 /mnt/.snapshots
mount -o noatime,nodiratime,compress=zstd,space_cache=v2,ssd,subvolid=5 /dev/sda2 /mnt/btrfs

mkdir /mnt/boot
mount /dev/sda1 /mnt/boot

pacman -Sy --noconfirm archlinux-keyring
pacstrap /mnt base linux-lts \
  intel-ucode btrfs-progs netctl openssh
genfstab -U /mnt >> /mnt/etc/fstab

echo archops > /mnt/etc/hostname
echo LANG=en_US.UTF-8 > /mnt/etc/locale.conf
sed -i '/#en_US/ s/^#//' /mnt/etc/locale.gen
arch-chroot /mnt/ locale-gen

echo KEYMAP=de-latin1 > /mnt/etc/vconsole.conf
echo FONT=lat9w-16 >> /mnt/etc/vconsole.conf

echo KEYMAP=us > /mnt/etc/vconsole.conf
echo FONT=lat9w-16 >> /mnt/etc/vconsole.conf

arch-chroot /mnt/ ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

cat <<EOF >> /mnt/etc/hosts
#<ip-address>	<hostname.domain.org>	<hostname>
127.0.0.1	archops.localdomain	archops
::1		localhost.localdomain	localhost
EOF

echo "root:archlinux" | arch-chroot /mnt/ chpasswd

arch-chroot /mnt/ mkinitcpio -p linux-lts

arch-chroot /mnt/ bootctl --path=/boot install

cat <<EOF > /mnt/boot/loader/entries/arch.conf
title Arch Linux
linux /vmlinuz-linux-lts
initrd /intel-ucode.img
initrd /initramfs-linux-lts.img
options net.ifnames=0 root=LABEL=ROOT rootflags=subvol=@ rw
EOF

cat <<EOF >> /mnt/boot/loader/loader.conf
default  arch.conf
timeout  4
console-mode max
editor   no
EOF

sed 's/192.168.1/10.211.55/g' /mnt/etc/netctl/examples/ethernet-static > /mnt/etc/netctl/eth0
arch-chroot /mnt/ netctl enable eth0
arch-chroot /mnt/ systemctl enable sshd

# Post install

#umount -R /mnt
#reboot

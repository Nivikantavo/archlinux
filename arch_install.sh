#!/usr/bin/env bash

parted -s /dev/sda mklabel msdos
parted -s /dev/sda mkpart primary 0% 100%
parted -s /dev/sda set 1 boot on

mkfs.ext4 /dev/sda1

mount /dev/sda1 /mnt

echo 'Server = https://mirror.yandex.ru/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist
pacstrap /mnt/ linux linux-firmware base grub xorg-server xorg-xinit firefox openbox tint2 ttf-liberation vim dhcpcd

genfstab -U /mnt >> /mnt/etc/fstab

echo 'otrs' > /mnt/etc/hostname

ln -sf /mnt/usr/share/zoneinfo/Europe/Moscow /mnt/etc/localtime
echo 'ru_RU.UTF-8 UTF-8' >> /mnt/etc/locale.gen
arch-chroot /mnt locale-gen
echo 'LANG="ru_RU.UTF-8"' >> /mnt/etc/locale.conf
echo 'FONT=cyr-sun16' >> /mnt/etc/vconsole.conf
echo 'KEYMAP=ru' >> /mnt/etc/vconsole.conf
echo 'KERNEL=="fb*", ACTION=="add", IMPORT{file}="/etc/vconsole.conf", RUN+="/usr/bin/setfont $env{FONT}"' >> /mnt/etc/udev/rules.d/96-fb-setfont.rules

echo '#!/usr/bin/env bash' >> /mnt/etc/skel/.xinitrc
echo 'tint2 &' >> /mnt/etc/skel/.xinitrc
echo 'exec openbox-session' >> /mnt/etc/skel/.xinitrc
arch-chroot /mnt useradd admin -m -G wheel -p "$(openssl passwd -1 'admin')"
arch-chroot /mnt sed -e '/trust\ use_uid/s/\#//' -i /etc/pam.d/su
arch-chroot /mnt sed -e '/trust\ use_uid/s/\#//' -i /etc/pam.d/su-l

arch-chroot /mnt grub-install --target=i386-pc --recheck /dev/sda
sed -i '/GRUB_TIMEOUT/s/5/0/g' /mnt/etc/default/grub
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

umount -R /mnt
reboot
#!/bin/bash
pacman -Sy --noconfirm archlinux-keyring
dd if=/dev/zero of=${1} bs=1M seek=1 count=1
sfdisk --wipe $1
echo ';' | sfdisk $1
mkfs.ext4 ${1}1
mount ${1}1 /mnt
dd if=/dev/zero of=/mnt/swapfile bs=1M count=4096 status=progress
chmod 0600 /mnt/swapfile
mkswap /mnt/swapfile
swapon /mnt/swapfile
mkdir /mnt/etc
genfstab -U /mnt >> /mnt/etc/fstab
pacstrap -K /mnt base linux linux-firmware
cat <<EOF > /mnt/bootstrap.sh
pacman -S --noconfirm grub xorg plasma-desktop konsole networkmanager pipewire-pulse plasma-pa firefox sudo sddm kdesu dolphin discover packagekit-qt5
systemctl enable sddm
systemctl enable NetworkManager
sed '/wheel.*ALL) ALL/s/^# //g' -i /etc/sudoers
useradd -m user
usermod -a -G wheel user
usermod --password '`openssl passwd -6 -in passwd.txt`' user
mkinitcpio -P
grub-install /dev/sda
grub-mkconfig >> /boot/grub/grub.cfg
EOF
cat <<EOF > /mnt/etc/sddm.conf
[Theme]
Current=breeze
EOF
arch-chroot /mnt /bin/bash /bootstrap.sh
rm /mnt/bootstrap.sh

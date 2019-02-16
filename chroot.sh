#!/bin/bash

#set the time zone
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc --utc
#set the locale
echo "en_US.UTF-8 UTF-8
zh_CN.UTF-8 UTF-8
zh_TW.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
echo ${hostname} > /etc/hostname
#create user
useradd -m -g users -G wheel -s /bin/bash ${username}
echo ${username}:${password} | chpasswd
#add to sudoers
echo "${username} ALL=(ALL) ALL" >> /etc/sudoers
#grub
pacman -S --noconfirm intel-ucode os-prober grub efibootmgr
#to use wifi-menu
pacman -S --noconfirm dialog wpa_supplicant
#DE base
pacman -S --noconfirm xorg xorg-xinit xf86-video-intel libinput alsa-utils pulseaudio
pacman -S --noconfirm mesa-demos  xfce4 xfce4-goodies lightdm lightdm-gtk-greeter gtk-engine-murrine
pacman -S --noconfirm udisks2 ntfs-3g gvfs networkmanager gnome-keyring libsecret network-manager-applet
pacman -S --noconfirm xfce4-notifyd ttf-dejavu wqy-microhei file-roller 
#applications
pacman -S  --noconfirm firefox vlc thunderbird git ffmpegthumbnailer gst-libav
#config system
systemctl enable NetworkManager 
systemctl enable lightdm 
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch --recheck
grub-mkconfig -o /boot/grub/grub.cfg 
exit


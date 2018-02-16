# !/bin/bash

fdisk -l
read -p "Fresh machine?(type y we will create partition automaticly[or n]): " fresh 
read -p "Type the disk you want to install[like: /dev/sda]: " disk
if [ ${fresh} == 'y' ]
    then
    parted ${disk} -s mklabel gpt mkpart ESP fat32 1M 513M mkpart primary ext4 513M 100% 
    mount ${disk}2 /mnt 
    mkdir /mnt/boot
    mount /dev/sda1 /mnt/boot 
    else
    read -p "Type the partition you want to install(like :/dev/sda2): " partition
    mount ${partition} /mnt 
    mkdir /mnt/boot
    mount /dev/sda1 /mnt/boot 
fi 
read -p "Type your hostname(like:Arch): " hostname
read -p "Type the username you want to create: " username
read -p "Type the password: " password
read -p "Are you from China?(type y we will replace the mirrorlist[or n]) :" china 
if [ ${china} == 'y' ]
    then
    mv mirrorlist /etc/pacman.d/mirrorlist
fi

pacstrap -i /mnt base base-devel
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt 
if [ ${china} == 'y' ]
    then
    echo "\nen_US.UTF-8 UTF-8\nzh_CN.UTF-8 UTF-8\nzh_TW.UTF-8 UTF-8" >> /etc/locale.genfstab
    else 
    echo "\nen_US.UTF-8 UTF-8" >> /etc/locale.gen 
fi
locale-gen 
echo LANG=en_US.UTF-8 > /etc/locale.conf
echo ${hostname} > /etc/hostname

#grub
pacman -S intel-ucode os-prober grub efibootmgr --noconfirm
#to use wifi-menu
pacman -S dialog wpa_supplicant --noconfirm
#install base DE
pacman -S xorg xorg-xinit xf86-video-intel libinput alsa-utils pulseaudio\
mesa-demos  xfce4 xfce4-goodies lightdm lightdm-gtk-greeter gtk-engine-murrine\
udisks2 ntfs-3g gvfs networkmanager gnome-keyring libsecret network-manager-applet\
xfce4-notifyd ttf-dejavu wqy-microhei file-roller --noconfirm
#install applications
pacman -S firefox vlc thunderbird
#create user
useradd -m -g users -G wheel -s /bin/bash ${username}
(echo ${password};sleep 1;echo ${password}) | passwd ${username} > /dev/null
#configure system
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch --recheck
grub-mkconfig -o /boot/grub/grub.cfg 
systemctl enable NetworkManager 
systemctl enable lightdm 

#reboot
echo "Completing..."
exit 
umount -R /mnt
reboot 


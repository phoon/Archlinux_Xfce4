# !/bin/bash

fdisk -l

read -p "Fresh machine?(type y we will create partition automaticly [ or n ]): " fresh 
read -p "Type the disk you want to install[like: /dev/sda]: " disk
if [ ${fresh} == "y" ]
    then
    parted ${disk} -s mklabel gpt mkpart ESP fat32 1M 513M mkpart primary ext4 514M 100%
    set 1 boot on
    mkfs.vfat -F32 ${disk}1 
    mkfs.ext4 ${disk}2
    mount ${disk}2 /mnt 
    mkdir /mnt/boot
    mount ${disk}1 /mnt/boot 
    else
    read -p "Type the partition you want to install(like :/dev/sda2): " partition
    mkfs.ext4 ${partition}
    mount ${partition} /mnt 
    mkdir /mnt/boot
    mount /dev/sda1 /mnt/boot 
fi 
read -p "Type your hostname(like:Arch): " hostname
read -p "Type the username you want to create: " username
read -p "Type the password: " password
read -p "Are you from China?(type y we will replace the mirrorlist[or n]) :" china 
if [ ${china} == "y" ]
    then
    mv mirrorlist /etc/pacman.d/mirrorlist
    echo "\nen_US.UTF-8 UTF-8\nzh_CN.UTF-8 UTF-8\nzh_TW.UTF-8 UTF-8" >> /mnt/etc/locale.genfstab
    else 
    echo "\nen_US.UTF-8 UTF-8" >> /mnt/etc/locale.gen 
fi

pacman -Syy
pacstrap -i /mnt base base-devel --noconfirm
genfstab -U /mnt >> /mnt/etc/fstab
# in arch-chroot

arch-chroot /mnt locale-gen 
arch-chroot /mnt echo LANG=en_US.UTF-8 > /etc/locale.conf
arch-chroot /mnt hostname ${hostname}
arch-chroot /mnt echo ${hostname} > /etc/hostname

#grub
arch-chroot /mnt pacman -S --noconfirm intel-ucode os-prober grub efibootmgr 
#to use wifi-menu
arch-chroot /mnt pacman -S --noconfirm dialog wpa_supplicant 
#install base DE
arch-chroot /mnt pacman -S --noconfirm xorg xorg-xinit xf86-video-intel libinput alsa-utils pulseaudio
arch-chroot /mnt pacman -S --noconfirm mesa-demos  xfce4 xfce4-goodies lightdm lightdm-gtk-greeter gtk-engine-murrine
arch-chroot /mnt pacman -S --noconfirm udisks2 ntfs-3g gvfs networkmanager gnome-keyring libsecret network-manager-applet
arch-chroot /mnt pacman -S --noconfirm xfce4-notifyd ttf-dejavu wqy-microhei file-roller 
#install applications
arch-chroot /mnt pacman -S  --noconfirm firefox vlc thunderbird 
#create user
arch-chroot /mnt useradd -m -g users -G wheel -s /bin/bash ${username}
arch-chroot /mnt echo ${username}:${password} | chpasswd
#configure system
arch-chroot /mnt systemctl enable NetworkManager 
arch-chroot /mnt systemctl enable lightdm 
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch --recheck
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg 


#reboot
echo "Completing..."
umount -R /mnt
reboot 



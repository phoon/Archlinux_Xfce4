#!/bin/bash 

export hostname
export username
export password

#partition 
echo -e "\033[35m Fresh machine and automatically installed with scripts?(y/n):  \033[0m"
read fresh 
echo -e "\033[35m Type the hostname you want to set up(eg. Arch): \033[0m"
read hostname
echo -e "\033[35m Type the username you want to create: \033[0m"
read username
echo -e "\033[35m Type the password of the user you just create: \033[0m"
read password
if [ $fresh == "y" ]
    then
    echo -e "\033[35m Type the disk you want to install(eg. /dev/sda): \033[0m"
    read disk
    parted ${disk} -s mklabel gpt mkpart ESP fat32 1M 513M mkpart primary ext4 514M 100%
    set 1 boot on
    mkfs.vfat -F32 ${disk}1 
    mkfs.ext4 ${disk}2
    mount ${disk}2 /mnt 
    mkdir /mnt/boot
    mount ${disk}1 /mnt/boot 
    else
    echo -e "\033[35m Type the partition you want to install(eg. /dev/sda2): \033[0m"
    read partition
    echo -e "\033[35m Type the EFI partition(usually is /dev/sdx1): \033[0m"
    read efi
    mkfs.ext4 ${partition}
    mount ${partion} /mnt
    mkdir /mnt/boot
    mount ${efi} /mnt/boot
fi 
wget https://raw.githubusercontent.com/phoon/Archlinux_Xfce4/master/mirrorlist
mv mirrorlist /etc/pacman.d/mirrorlist
pacman -Syy
pacstrap -i /mnt base base-devel linux linux-firmware --noconfirm
genfstab -U /mnt >> /mnt/etc/fstab

#chroot
wget https://raw.githubusercontent.com/iPeven/Archlinux_Xfce4/master/chroot.sh
mv chroot.sh /mnt/root/chroot.sh
chmod +x /mnt/root/chroot.sh
arch-chroot /mnt /root/chroot.sh
umount -R /mnt/boot
umount -R /mnt
reboot

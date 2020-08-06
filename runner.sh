#!/bin/bash

echo
echo
echo
echo "###########################################"
echo "#                                         #"
echo "#             made by Rouchage            #"
echo "#                                         #"
echo "###########################################"
echo "#                                         #"
echo "#             ATTENTION !!!               #"
echo "# Please read carefully and then write    #"
echo "# Otherwise may occur loss of information #"
echo "#                                         #"
echo "###########################################"
echo
echo
echo
read -p "PRESS enter TO CONTINUE"
echo

##################
# პირველი ნაწილი #
##################

### 10 fastest mirrors
reflector --verbose --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
echo

# 
timedatectl set-ntp true

function ask_yes_or_no() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}



lsblk
echo
echo ENTER \"/\" PARTITION NAME, LIKE THIS: sda1 or sda2
read RootPartition
mkfs.ext4 -Fq /dev/$RootPartition
echo partition formatted
echo

echo ENTER \"/home\" PARTITION NAME, LIKE THIS: sda1 or sda2
read HomePartition

if [[ "no" == $(ask_yes_or_no "FORMAT /home PARTITION?") || "no" == $(ask_yes_or_no "AGAIN, FORMAT /home PARTITION?") ]]
then
    echo /home partition not formatted
else 
    mkfs.ext4 -Fq /dev/$HomePartition
fi

#
mount /dev/$RootPartition /mnt/
mkdir /mnt/home
mount /dev/$HomePartition /mnt/home/



pacstrap /mnt base base-devel linux
genfstab -U /mnt >> /mnt/etc/fstab
echo base system installed
echo



##################
#  მეორე ნაწილი  #
##################

### chroot ში სკრიპტის შექმნა, პერმიშენი
cat > /mnt/runner2.sh <<EOF
#!/bin/bash


# start here
ln -sf /usr/share/zoneinfo/Asia/Tbilisi /etc/localtime
hwclock --systohc
echo time set done
echo

echo -e "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo -e "LANG=en_US.UTF-8" > /etc/locale.conf
echo locale settings done
echo

# hostname
echo ENTER HOSTNAME:
read HostnameSaxeli
echo -e "\$HostnameSaxeli" > /etc/hostname
echo -e "127.0.0.1 localhost\n::1 localhost\n127.0.1.1 \$HostnameSaxeli.localdomain \$HostnameSaxeli" > /etc/hosts
echo hostname done
echo

# root password
echo ENTER root PASSWORD:
passwd
echo root password done
echo

# Username - კითხვა
echo ADD A NEW USER, ENTER USERNAME:
read MomxmareblisSaxeli
useradd -m -G wheel \$MomxmareblisSaxeli
echo ENTER PASSWORD FOR \$MomxmareblisSaxeli
passwd \$MomxmareblisSaxeli
echo user added
echo


# გრაბი - კითხვა
lsblk
echo
echo "WHERE TO INSTALL GRUB?(ENTER JUST PARTITION NAME, LIKE: sda or sdb):"
read GrubMisamarti
echo

noGUI=false
# დიალოგი
function ask_yes_or_no() {
    read -p "\$1 ([y]es or [N]o): "
    case \$(echo \$REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}

if [[ "yes" == \$(ask_yes_or_no "DO YOU WANT TO INSTALL GUI?") || "yes" == \$(ask_yes_or_no "AGAIN, DO YOU WANT TO INSTALL GUI?") ]]
then
    # gui select
    echo CHOOSE DESKTOP. ENTER \"xfce\" or \"gnome\":
    read Desktopi  
else 
    # noGUI setup:
    noGUI=true
fi


# ბარიერი
pacman -Sy sudo nano grub bash-completion os-prober ntfs-3g --noconfirm
# ბარიერი


# enable wheel
echo -e "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/99_wheel

# გრაბი - ინსტალაცია
grub-install --force /dev/\$GrubMisamarti
grub-mkconfig -o /boot/grub/grub.cfg
echo grub done
echo



if [ "\$noGUI" = true ]
then
  pacman -S dhcpcd mc --noconfirm
  systemctl enable dhcpcd
else
 if [ "\$Desktopi" = "xfce" ]
 then
   pacman -S mousepad vlc chromium pepper-flash pulseaudio ttf-dejavu ttf-liberation ttf-joypixels xfce4 xfce4-notifyd xfce4-pulseaudio-plugin xfce4-screenshooter xfce4-xkb-plugin thunar-archive-plugin pavucontrol onboard lxdm engrampa unrar p7zip deadbeef dhcpcd gvfs gvfs-mtp --noconfirm
   systemctl enable lxdm
   systemctl enable dhcpcd
 elif [ "\$Desktopi" = "gnome" ]
 then
   pacman -S vlc chromium pepper-flash ttf-dejavu ttf-liberation ttf-joypixels gnome networkmanager gvfs gvfs-mtp --noconfirm
   systemctl enable gdm
   systemctl enable NetworkManager
 fi
fi


echo
echo
echo
echo "##################################"
echo "#                                #"
echo "#        made by Rouchage        #"
echo "#                                #"
echo "##################################"
echo "#                                #"
echo "#     Installation completed!    #"
echo "#                                #"
echo "##################################"
echo
echo
echo

# suicide
rm runner2.sh

EOF


# executable პერმიშენი
chmod +x /mnt/runner2.sh

echo
echo
echo
echo "###########################################"
echo "#                                         #"
echo "#    NOW SYSTEM IS GOING IN \"chroot\"      #"
echo "# WHERE YOU MUST LAUNCH SCRIPT BY TYPING: #"
echo "#                                         #"
echo "#              ./runner2.sh               #"
echo "#                                         #"
echo "###########################################"
echo
echo
echo

read -p "PRESS enter TO CONTINUE"


#
arch-chroot /mnt





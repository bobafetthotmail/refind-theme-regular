#!/bin/bash

clear
cd $HOME
echo "Downloading Refind Theme to "$HOME" [NOT DONE]"
git clone https://github.com/bobafetthotmail/refind-theme-regular.git &> /dev/null
sleep 1
clear
echo "Downloading Refind Theme to "$HOME" [DONE]"
echo "Deleting older installed versions (If any) [NOT DONE]"
sudo rm -rf /boot/efi/EFI/refind/{regular-theme,refind-theme-regular}
sleep 1
clear
echo "Downloading Refind Theme to "$HOME" [DONE]"
echo "Deleteting older installed versions (If any) [DONE]"
echo "Copying Theme to /boot/efi/EFI/refind/ [NOT DONE]"
sudo cp -r refind-theme-regular /boot/efi/EFI/refind/
sleep 1
clear
echo "Downloading Refind Theme to "$HOME" [DONE]"
echo "Deleteting older installed versions (If any) [DONE]"
echo "Copying Theme to /boot/efi/EFI/refind/ [DONE]"
echo "Removing unused directories [NOT DONE]"
sudo rm -rf /boot/efi/EFI/refind/refind-theme-regular/{src,.git}
sleep 1
clear
echo "Downloading Refind Theme to "$HOME" [DONE]"
echo "Deleteting older installed versions (If any) [DONE]"
echo "Copying Theme to /boot/efi/EFI/refind/ [DONE]"
echo "Removing unused directories [DONE]"
echo "Removing old themes [NOT DONE]"
sed '/include/d' ./boot/efi/EFI/refind/refind.conf &> /dev/null
sleep 1
clear
echo "Downloading Refind Theme to "$HOME" [DONE]"
echo "Deleteting older installed versions (If any) [DONE]"
echo "Copying Theme to /boot/efi/EFI/refind/ [DONE]"
echo "Removing unused directories [DONE]"
echo "Removing old themes [DONE]"
echo "Updating theme.config [NOT DONE]"
echo "include refind-theme-regular/theme.conf" >> /boot/efi/EFI/refind/refind.conf
sleep 1
clear
echo "Downloading Refind Theme to "$HOME" [DONE]"
echo "Deleteting older installed versions (If any) [DONE]"
echo "Copying Theme to /boot/efi/EFI/refind/ [DONE]"
echo "Removing unused directories [DONE]"
echo "Removing old themes [DONE]"
echo "Updating theme.config [DONE]"
echo "Deleting Theme [NOT DONE]"
cd $HOME
sudo rm -r refind-theme-regular
sleep 1
clear
echo "Downloading Refind Theme to "$HOME" [DONE]"
echo "Deleteting older installed versions (If any) [DONE]"
echo "Copying Theme to /boot/efi/EFI/refind/ [DONE]"
echo "Removing unused directories [DONE]"
echo "Removing old themes [DONE]"
echo "Updating theme.config [DONE]"
echo "Deleting Theme [DONE]"
sleep 1
echo "  "
echo "Thank you for installing refind-theme-regular."
echo "NOTE: If your not geting your full resolution then try disabling the CSM in your UEFI settings." 

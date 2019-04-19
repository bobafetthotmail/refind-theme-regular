#!/bin/sh

# An installer for refind-theme-regular by Munlik

#Check if root
[[ $EUID -ne 0 ]] && echo "This script must be run as root." && exit 1

clear

#Clone the theme
echo -n "Downloading rEFInd theme Regular to $PWD"
git clone https://github.com/diddypod/refind-theme-regular.git &> /dev/null
echo " - [DONE]"

#Useful formatting tags
bold=$(tput bold)
normal=$(tput sgr0)

#Set install path
echo "Enter rEFInd install location"
read -e -p "Default - ${bold}/boot/efi/EFI/refind/${normal}: " location
if test -z "$location";
then
    location="/boot/efi/EFI/refind/"
fi
if test "${location: -1}" != "/"
then
    location="$location/"
fi

#Set icon size
echo "Pick an icon size: (larger icons look better on bigger and denser displays)"
read -p "${bold}1: small (128px-48px)${normal}, 2: medium (256px-96px), 3: large (384px-144px), 4: extra-large (512px-192px): " size_select
if test -z "$size_select";
then
    size_select=1
fi
case "$size_select" in
    1)
        size_big="128"
        size_small="48"
        break
        ;;
    2)
        size_big="256"
        size_small="96"
        break
        ;;
    3)
        size_big="384"
        size_small="144"
        break
        ;;
    4)
        size_big="512"
        size_small="192"
        break
        ;;
    *)
        echo "Incorrect choice. Exiting."
        exit 1
        ;;
esac
echo "Selected size - big icons: $size_big px, small icons: $size_small px"

#Set theme color
echo "Select a theme color"
read -p "${bold}1: light${normal}, 2: dark: " theme_select
if test -z "$theme_select";
then
    theme_select=1
fi
case "$theme_select" in
    1)
        theme_name="light"
        theme_path=""
        break
        ;;
    2)
        theme_name="dark"
        theme_path="_dark"
        break
        ;;
    *)
        echo "Incorrect choice. Exiting."
        exit 1
        ;;
esac
echo "Selected theme - $theme_name"

#Uncomment relevant lines from src/theme.conf
echo -n "Generating theme file theme.conf"
cd refind-theme-regular
cp src/theme.conf theme.conf
sed -i "s/#icons_dir refind-theme-regular\/icons\/$size_big-$size_small/icons_dir refind-theme-regular\/icons\/$size_big-$size_small/" theme.conf
sed -i "s/#big_icon_size $size_big/big_icon_size $size_big/" theme.conf
sed -i "s/#small_icon_size $size_small/small_icon_size $size_small/" theme.conf
sed -i "s/#banner refind-theme-regular\/icons\/$size_big-$size_small\/bg$theme_path.png/banner refind-theme-regular\/icons\/$size_big-$size_small\/bg$theme_path.png/" theme.conf
sed -i "s/#selection_big refind-theme-regular\/icons\/$size_big-$size_small\/selection$theme_path-big.png/selection_big refind-theme-regular\/icons\/$size_big-$size_small\/selection$theme_path-big.png/" theme.conf
sed -i "s/#selection_small refind-theme-regular\/icons\/$size_big-$size_small\/selection$theme_path-small.png/selection_small refind-theme-regular\/icons\/$size_big-$size_small\/selection$theme_path-small.png/" theme.conf
cd ..
echo " - [DONE]"

#Clean up
echo -n "Removing unused directories"
rm -rf refind-theme-regular/{src,.git}
rm -rf refind-theme-regular/install.sh
echo " - [DONE]"

#Remove previous installs
echo -n "Deleting older installed versions (if any)"
rm -rf "$location"{regular-theme,refind-theme-regular}
echo " - [DONE]"

#Copy theme setup folders
echo -n "Copying theme to $location"
cp -r refind-theme-regular "$location"
echo " - [DONE]"

#Edit refind.conf - remove older themes
echo -n "Removing old themes from refind.conf"
sed --in-place=".bak" 's/^\s*include/# (disabled) include/' "$location"refind.conf
echo " - [DONE]"

#Edit refind.conf - add new theme
echo -n "Updating refind.conf"
echo "
# Load rEFInd theme Regular
include refind-theme-regular/theme.conf" | tee -a "$location"refind.conf &> /dev/null
echo " - [DONE]"

#Clean up - remove download
read -p "Delete download? (${bold}Y${normal}/n): " del_confirm
if test -z "$del_confirm";
then
    del_confirm="y"
fi
case "$del_confirm" in
    y|Y)
        echo -n "Deleting download"
        rm -r refind-theme-regular
        echo " - [DONE]"
        break
        ;;
    *)
        break
        ;;
esac

echo "Thank you for installing rEFInd theme Regular."
echo "NOTE: If your not geting your full resolution or have color issues then try disabling the CSM in your UEFI settings."

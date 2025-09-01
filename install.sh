#!/usr/bin/env bash
set -euo pipefail
# Installer/Uninstaller for rEFInd theme "Regular"
# Supports macOS + Linux
# Modes:
#   default   -> install
#   --test    -> install (dry run, no changes)
#   --uninstall -> remove theme and restore backup

#------------------------------
# Mode handling
#------------------------------
TEST_MODE=false
UNINSTALL_MODE=false

if [[ "${1:-}" == "--test" ]]; then
    TEST_MODE=true
    echo "🧪 Running in TEST MODE: No changes will be made."
elif [[ "${1:-}" == "--uninstall" ]]; then
    UNINSTALL_MODE=true
    echo "🗑️  Running in UNINSTALL MODE."
fi

#------------------------------
# Helpers
#------------------------------
run_or_echo() {
    if $TEST_MODE; then
        echo "TEST: $*"
    else
        eval "$@"
    fi
}

sedi() {
    if [[ "$(uname)" == "Darwin" ]]; then
        run_or_echo "sed -i '' \"$*\""
    else
        run_or_echo "sed -i \"$*\""
    fi
}

#------------------------------
# macOS checks
#------------------------------
darwin() {
    echo "🔍 Checking System Integrity Protection (SIP)..."
    if command -v csrutil &>/dev/null; then
        sip_status=$(csrutil status 2>/dev/null || true)
        if [[ "$sip_status" != *"disabled"* ]]; then
            echo "❌ ERROR: System Integrity Protection is enabled. Please disable it!"
            echo "👉 Reboot into Recovery Mode and run: csrutil disable"
            exit 1
        fi
    else
        echo "⚠️ Could not detect csrutil. Make sure SIP is disabled!"
        exit 1
    fi

    if [[ $EUID -ne 0 ]]; then
        echo "❌ ERROR: Please run this script as root (use: sudo ./install.sh)"
        exit 1
    fi
    echo "✅ macOS checks passed."
}

#------------------------------
# Linux checks
#------------------------------
linux() {
    if [[ $EUID -ne 0 ]]; then
        echo "❌ ERROR: This script must be run as root (sudo ./install.sh)."
        exit 1
    fi
    echo "✅ Linux checks passed."
}

#------------------------------
# Ask user which OS to run as
#------------------------------
if ! $UNINSTALL_MODE; then
    clear
    echo "⚠️  WARNING: This script modifies your EFI partition and bootloader settings!"
    echo "   Running it incorrectly may result in an unbootable system."
    echo "   Make sure you have backups and know how to recover!"
    echo
    echo "Which system are you running on?"
    read -p "[1] macOS   [2] Linux   > " os_choice
else
    os_choice=0
fi

actual_os=$(uname)

if ! $UNINSTALL_MODE; then
    case "$os_choice" in
        1) 
            if [[ "$actual_os" != "Darwin" ]]; then
                echo "⚠️ WARNING: You selected macOS, but this system reports: $actual_os"
                read -p "Are you sure you want to continue as macOS? (y/N): " confirm_os
                [[ "${confirm_os,,}" != "y" ]] && echo "Exiting." && exit 1
            fi
            darwin
            ;;
        2)
            if [[ "$actual_os" == "Darwin" ]]; then
                echo "⚠️ WARNING: You selected Linux, but this system is macOS."
                read -p "Are you absolutely sure you want to continue as Linux? (y/N): " confirm_linux
                [[ "${confirm_linux,,}" != "y" ]] && echo "Exiting." && exit 1
            fi
            linux
            ;;
        *)
            echo "Invalid choice. Exiting."
            exit 1
            ;;
    esac
fi

#------------------------------
# Uninstall mode
#------------------------------
if $UNINSTALL_MODE; then
    echo "Uninstalling rEFInd theme Regular..."
    if [[ "$actual_os" == "Darwin" ]]; then
        refind_dir_default="/Volumes/ESP/EFI/refind"
    else
        refind_dir_default="/boot/efi/EFI/refind"
    fi

    echo "Where is rEFInd installed?"
    read -e -p "Default - $refind_dir_default: " refind_dir
    refind_dir=${refind_dir:-$refind_dir_default}

    if [[ ! -d "${refind_dir}" ]]; then
        echo "That folder doesn’t exist. Aborting."
        exit 1
    fi

    echo "🗑️  Removing theme directory..."
    run_or_echo "rm -rf \"${refind_dir}/themes/refind-theme-regular\""

    if [[ -f "${refind_dir}/refind.conf.bak" ]]; then
        echo "♻️  Restoring backup refind.conf..."
        run_or_echo "mv \"${refind_dir}/refind.conf.bak\" \"${refind_dir}/refind.conf\""
    else
        echo "⚠️ No backup refind.conf.bak found. Manual cleanup may be needed."
    fi

    echo "✅ Uninstall complete."
    exit 0
fi

#------------------------------
# Install mode (default / --test)
#------------------------------
if ! command -v git &> /dev/null; then
    echo "git is not installed!"
    if [[ "$os_choice" == "1" ]]; then
        echo "On macOS you can install it with: brew install git"
    else
        echo "On Ubuntu/Debian you can install it with: sudo apt install git"
    fi
    exit 1
fi

theme_source_directory=$(mktemp -d -t refind-theme-regular-XXXXXX)
cd "${theme_source_directory}"
echo "⬇️  Downloading rEFInd theme Regular..."
run_or_echo "git clone https://github.com/bobafetthotmail/refind-theme-regular.git"

bold=$(tput bold)
normal=$(tput sgr0)

if [[ "$os_choice" == "1" ]]; then
    refind_dir_default="/Volumes/ESP/EFI/refind"
else
    refind_dir_default="/boot/efi/EFI/refind"
fi

echo "Where is rEFInd installed?"
read -e -p "Default - ${bold}${refind_dir_default}${normal}: " refind_dir
refind_dir=${refind_dir:-$refind_dir_default}

if [[ ! -d "${refind_dir}" ]]; then
    echo "That folder doesn’t exist. Aborting."
    exit 1
fi

if command -v realpath &>/dev/null; then
    refind_dir=$(realpath -s "$refind_dir")
else
    refind_dir=$(cd "$refind_dir" && pwd)
fi

echo "Pick an icon size:"
read -p "${bold}1: small${normal}, 2: medium, 3: large, 4: extra-large: " size_select
size_select=${size_select:-1}
case "$size_select" in
    1) size_big="128"; size_small="48";;
    2) size_big="256"; size_small="96";;
    3) size_big="384"; size_small="144";;
    4) size_big="512"; size_small="192";;
    *) echo "Incorrect choice. Exiting."; exit 1;;
esac

echo "Select a theme color"
read -p "${bold}1: light${normal}, 2: dark: " theme_select
theme_select=${theme_select:-1}
case "$theme_select" in
    1) theme_name="light"; theme_path="";;
    2) theme_name="dark"; theme_path="_dark";;
    *) echo "Incorrect choice. Exiting."; exit 1;;
esac

cd refind-theme-regular
run_or_echo "cp src/theme.conf theme.conf"
sedi "s/#icons_dir.*/icons_dir themes\/refind-theme-regular\/icons\/$size_big-$size_small/" theme.conf
sedi "s/#big_icon_size.*/big_icon_size $size_big/" theme.conf
sedi "s/#small_icon_size.*/small_icon_size $size_small/" theme.conf
sedi "s/#banner.*/banner themes\/refind-theme-regular\/icons\/$size_big-$size_small\/bg$theme_path.png/" theme.conf
sedi "s/#selection_big.*/selection_big themes\/refind-theme-regular\/icons\/$size_big-$size_small\/selection$theme_path-big.png/" theme.conf
sedi "s/#selection_small.*/selection_small themes\/refind-theme-regular\/icons\/$size_big-$size_small\/selection$theme_path-small.png/" theme.conf
cd ..

run_or_echo "rm -rf refind-theme-regular/{src,.git}"
run_or_echo "rm -rf refind-theme-regular/install.sh"
run_or_echo "rm -rf \"${refind_dir}\"/{regular-theme,refind-theme-regular}"
run_or_echo "rm -rf \"${refind_dir}\"/themes/{regular-theme,refind-theme-regular}"
run_or_echo "mkdir -p \"${refind_dir}/themes\""
run_or_echo "cp -r refind-theme-regular \"${refind_dir}/themes\""

echo "Cleaning old themes from refind.conf..."
read -p "Do you have a secondary config file to preserve? Default: N (y/N): " config_confirm
config_confirm=${config_confirm:-n}
if [[ "$config_confirm" =~ [yY] ]]; then
    read -p "Enter the name of the config file to preserve (eg: manual.conf): " configname
    configname=${configname:-'^#'}
    run_or_echo "sed --in-place='.bak' \"/$configname/! s/^\\s*include/# (disabled) include/\" \"${refind_dir}/refind.conf\""
else
    run_or_echo "sed --in-place='.bak' 's/^\\s*include/# (disabled) include/' \"${refind_dir}/refind.conf\""
fi

echo "
# Load rEFInd theme Regular
include themes/refind-theme-regular/theme.conf" | run_or_echo "tee -a \"${refind_dir}/refind.conf\" >/dev/null"

read -p "Delete temporary download folder? (Y/n): " del_confirm
del_confirm=${del_confirm:-y}
if [[ "$del_confirm" =~ [yY] ]]; then
    run_or_echo "rm -r \"${theme_source_directory}\""
fi

echo "✅ Installation finished. Enjoy your new rEFInd theme!"

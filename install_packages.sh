#!/bin/bash
function check_root() {
    # Checking for root access and proceed if it is present
    ROOT_UID=0
    if [[ ! "${UID}" -eq "${ROOT_UID}" ]]; then
        # Error message
        echo 'Run me as root.'
        echo 'Try sudo ./install_packages.sh'
        exit 1
    fi
}

check_root

# Define a list of packages to install
pacman_packages=(
    "vim"
    "neofetch"
    "htop"
    "curl"
    "wget"
    "tar"
    "git"
    "jdk-openjdk"
    "libreoffice-fresh"
    "vlc"
    "discord"
    "thunderbird"
    "firefox"
    "torbrowser-launcher"
    "thunderbird"
    "grub-customizer"
    "flatpak"

    # Blutooth
    "bluez"
    "blueman"
    "bluez-utils"
)


aur_packages=(
    "pamac-aur"
    "brave-bin"
    "visual-studio-code-bin"
    "timeshift"
    "slack-desktop-wayland"
    "spotify"
    "notion-app-electron"
    "google-chrome"
    "p3x-onenote"
)

flatpak_packages={}

# Prompt to install GNOME packages
read -p "Do you want to install GNOME packages? (y/n): " install_gnome

if [[ $install_gnome == "y" ]]; then
    aur_packages+=(
        "gnome-shell-extension-clipboard-history"
        "gnome-shell-extension-gsconnect"
        "gnome-shell-extension-nightthemeswitcher"
        )

    pacman_packages+=(
        "gnome-browser-connector"
    )

    flatpak_packages+=(
        "flathub"
        "com.mattjakeman.ExtensionManager"
    )
fi

# Prompt to install Wayland packages
read -p "Do you want to install Wayland packages? (y/n): " install_wayland

if [[ $install_wayland == "y" ]]; then
    pacman_packages+=(
         # Fix screen sharing in Wayland for discord
        "xwaylandvideobridge"
    )
fi

# Prompt to install Wayland packages
read -p "Do you want to install Dev packages? (y/n): " install_dev

if [[ $install_dev == "y" ]]; then
    pacman_packages+=(
        "docker"
	    "docker-compose"
        "aws-cli-v2"
    )
    aur_packages+=(
        "rider"
        "postman-bin"
	    "datagrip"
        "docker-desktop"
    )
fi

# Update system package database
echo "Updating system package database..."
sudo pacman -Sy

echo "Installing Pacman packages..."
# Loop through the list of packages and install if not already installed
for package in "${pacman_packages[@]}"; do
    if ! pacman -Qi "$package" &> /dev/null; then
        echo "Installing package: $package"
        sudo pacman -S "$package" --noconfirm
    else
        echo "Package $package is already installed."
    fi
done

# Install Yay
if ! yay --version &> /dev/null; then
    echo "yay is not installed, proceeding with installation..."
    # Install base-devel and git if they are not already installed
    sudo pacman -S --needed base-devel git

    # Temporarily change to a temporary directory for yay installation
    pushd "$(mktemp -d)" || exit 1

    # Clone yay from AUR
    git clone https://aur.archlinux.org/yay.git
    cd yay || exit 1

    # Build and install yay
    makepkg -si

    # Return to the original directory
    popd
fi

echo "Installing AUR packages..."
# Loop through the list and install each package if it is not already installed
for package in "${aur_packages[@]}"; do
    # Check if the package is already installed
    if yay -Q $package &> /dev/null; then
        echo "Package $package is already installed."
    else
        echo "Installing $package..."
        yay -S "$package" --noconfirm
    fi
done

for package in "${flatpak_packages[@]}"; do
    # Check if the package is already installed
    if flatpak list | grep $package &> /dev/null; then
        echo "Package $package is already installed."
    else
        echo "Installing $package..."
        flatpak install $package
    fi
done


echo "Installation process complete."
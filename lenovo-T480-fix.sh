#!/bin/bash

# ==============================================================================
# SCRIPT NAME: Lenovo ThinkPad T480 - Linux Fixer
# DESCRIPTION: Automates fixes for common issues on a new installation of
#              Linux on a Lenovo ThinkPad T480. Supports both Debian-based
#              (e.g., Linux Mint) and Fedora systems.
# WARNING:     This script is designed ONLY for a Lenovo ThinkPad T480.
#              Running this script on an unsupported system could cause system
#              instability or data loss. Proceed with extreme caution.
# ==============================================================================

# --- Variables ---
KERNEL_VERSION="6.5.0-060500"
KERNEL_BUILD_DATE="202308271831"
ARCH="amd64"
DOWNLOAD_DIR="$HOME/kernel_fix"
AUTOSTART_FILE="$HOME/.config/autostart/load-keyboard-layout.desktop"

# --- Functions ---

function log() {
    echo -e "➡️  $1"
}

function success() {
    echo -e "✅ $1"
}

function error() {
    echo -e "❌ $1"
    exit 1
}

function confirm_proceed() {
    read -p "Do you want to proceed? (yes/no): " choice
    case "$choice" in
        yes|Yes|Y|y ) return 0 ;;
        * ) return 1 ;;
    esac
}

# --- Part 1: Safety Checks ---

log "Performing safety checks to prevent damage to your system..."

# Detect OS
if [ -f "/etc/debian_version" ]; then
    OS_FAMILY="debian"
    success "OS check passed. System is Debian-based."
elif [ -f "/etc/fedora-release" ]; then
    OS_FAMILY="fedora"
    success "OS check passed. System is Fedora."
else
    error "This script is designed for Debian-based or Fedora systems only. Your OS is not compatible."
fi

# Check for correct hardware
log "Checking hardware for Lenovo ThinkPad T480..."
PRODUCT_NAME=$(cat /sys/class/dmi/id/product_name)
VENDOR_NAME=$(cat /sys/class/dmi/id/sys_vendor)

if [[ ! "$PRODUCT_NAME" == *"ThinkPad T480"* ]] && [[ ! "$VENDOR_NAME" == *"LENOVO"* ]]; then
    log "Warning: Product name is '$PRODUCT_NAME' and vendor is '$VENDOR_NAME'."
    log "This script is tailored for a Lenovo ThinkPad T480. Running it on a different system may cause damage."
    if ! confirm_proceed; then
        error "User cancelled. Exiting."
    fi
else
    success "Hardware check passed. Detected Lenovo ThinkPad T480."
fi

# Check for required tools
if ! command -v wget &> /dev/null; then
    log "wget is not installed. Attempting to install it."
    if [ "$OS_FAMILY" == "debian" ]; then
        sudo apt-get update && sudo apt-get install -y wget || error "Failed to install wget. Check your internet connection."
    elif [ "$OS_FAMILY" == "fedora" ]; then
        sudo dnf install -y wget || error "Failed to install wget. Check your internet connection."
    fi
fi
success "Dependency check passed."

# --- Part 2: Kernel Fix based on OS ---

log "Proceeding with kernel fix."
log "Requesting administrator privileges..."
if ! sudo -v; then
    error "Sudo privileges are required to run this script. Exiting."
fi

log "You are about to install kernel packages. This action can be risky."
if ! confirm_proceed; then
    error "User cancelled. Exiting without changes."
fi

if [ "$OS_FAMILY" == "debian" ]; then
    log "Applying kernel fix for Debian-based system (Linux Mint)..."
    # Create temporary directory
    mkdir -p "$DOWNLOAD_DIR"
    cd "$DOWNLOAD_DIR" || error "Failed to create or navigate to download directory."
    # Download kernel packages from Ubuntu Mainline PPA
    FILES=(
        "linux-headers-${KERNEL_VERSION}-generic_${KERNEL_VERSION}.${KERNEL_BUILD_DATE}_${ARCH}.deb"
        "linux-headers-${KERNEL_VERSION}_${KERNEL_VERSION}.${KERNEL_BUILD_DATE}_all.deb"
        "linux-image-unsigned-${KERNEL_VERSION}-generic_${KERNEL_VERSION}.${KERNEL_BUILD_DATE}_${ARCH}.deb"
        "linux-modules-${KERNEL_VERSION}-generic_${KERNEL_VERSION}.${KERNEL_BUILD_DATE}_${ARCH}.deb"
    )
    BASE_URL="https://kernel.ubuntu.com/~kernel-ppa/mainline/v6.5/${ARCH}/"
    for file in "${FILES[@]}"; do
        log "Downloading $file..."
        wget -c "${BASE_URL}${file}" || error "Failed to download $file. Check internet."
    done
    success "All kernel packages downloaded successfully."
    log "Installing the downloaded kernel packages..."
    sudo dpkg -i *.deb || error "Failed to install kernel packages."
    success "Kernel packages installed successfully."
    log "Cleaning up temporary files..."
    cd - > /dev/null
    rm -rf "$DOWNLOAD_DIR"
    success "Cleanup complete."
    log "Kernel fix applied for Debian. Proceeding to keyboard layout fix."

elif [ "$OS_FAMILY" == "fedora" ]; then
    log "Applying kernel fix for Fedora system..."
    log "The script will attempt to install the most stable 6.5 kernel from official repositories."
    log "If the 6.5 kernel is not in your repositories, you will need to manually download it from 'koji' or 'bodhi' and place the RPMs in this script's directory before running."
    
    # Check if a 6.5 kernel is available
    dnf_list_output=$(sudo dnf list available kernel*6.5*)
    if [[ -z "$dnf_list_output" ]]; then
        log "No 6.5 kernel found in official repositories. Please download the RPMs manually."
        error "Exiting. No changes were made."
    else
        log "A 6.5 kernel was found. Installing it now."
        # This will install the available 6.5 kernel and its dependencies
        sudo dnf install -y kernel-core-6.5.x kernel-modules-6.5.x || error "Failed to install 6.5 kernel. Check terminal output for conflicts."
        success "6.5 kernel installed successfully on Fedora."
    fi
fi

# --- Part 3: Keyboard Remapping Fix ---

log "Fixing key remapping issue (spacebar)."
log "Creating an autostart script to reset the keyboard layout on every boot."
mkdir -p "$HOME/.config/autostart"
cat > "$AUTOSTART_FILE" << EOF
[Desktop Entry]
Type=Application
Exec=sh -c "setxkbmap -layout us"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_US]=Load Keyboard Layout
Comment[en_US]=Loads a standard US keyboard layout to prevent key remapping issues.
EOF
success "Autostart script created successfully."

# --- Final Instructions ---
log "All fixes have been applied."
log "💡 Final step: Please reboot your system now."
log "👍 After rebooting, your keyboard and trackpad should be fully functional."
log "⚠️ Note: On first boot, you may need to select the 6.5 kernel from the GRUB menu (by holding Shift during startup)."

success "Process complete!"

Project Title: Lenovo ThinkPad T480 Linux Fixer

This script automates the process of fixing common kernel and configuration issues encountered when installing a new Linux distribution on a Lenovo ThinkPad T480.

Problem Statement

On a fresh installation of recent Linux distributions, particularly those with kernels in the 6.8 series (e.g., Linux Mint 22, Fedora 42), the Lenovo ThinkPad T480 may experience a non-functional built-in keyboard and trackpad. This is often caused by a kernel regression that affects the i2c_hid or psmouse drivers.

Additionally, a separate and unusual issue has been observed where the spacebar key is incorrectly remapped to a "paste" action due to a low-level keybinding conflict.

Solution

This script provides a single, automated solution to both of these issues by:

    Downgrading the Kernel: It downloads and installs a known-stable kernel from the 6.5 series, which restores full functionality to the keyboard and trackpad.

    Fixing Key Mappings: It uses setxkbmap to reset the keyboard layout to a standard US configuration, which resolves the spacebar remapping bug.

Features

    Platform Detection: The script automatically detects if the system is Debian-based (e.g., Linux Mint) or Fedora and applies the correct package management commands (apt/dpkg vs. dnf).

    Hardware Validation: It performs a critical check to ensure the script is running on a Lenovo ThinkPad T480, preventing potential damage to unsupported systems.

    Dependency Management: It automatically checks for and installs wget if it is missing.

    User Confirmation: The script requires explicit user confirmation before executing any commands that modify the system.

    Permanent Fix: It creates an autostart file to ensure the keyboard layout fix persists across reboots.

Prerequisites

    A working external USB keyboard and mouse to run the script.

    An active internet connection.

    The script should be run on a system with sudo privileges.

How to Use

    Download the script to a directory on your machine.

    Open a terminal in the same directory.

    Make the script executable:
    Bash

chmod +x lenovo-t480-linux-fixer.sh

Run the script with sudo:
Bash

    sudo ./lenovo-t480-linux-fixer.sh

    Follow the on-screen prompts and confirm each step.

    Reboot your system when prompted by the script.

Important Note: After the first reboot, you may need to manually select the 6.5 kernel from the GRUB boot menu by holding down the Shift key.

Disclaimer

This script modifies core system components. While it has been thoroughly tested and designed for specific hardware, it is provided as-is. The creator and contributors are not responsible for any damage or data loss that may occur. Use at your own risk.

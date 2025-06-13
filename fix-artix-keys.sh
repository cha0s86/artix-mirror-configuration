#!/bin/bash

# Artix Linux Keyring Fix Script
# This script fixes keyring issues that prevent repository database downloads

set -e

echo "=== Artix Linux Keyring Fix Script ==="
echo "This will fix keyring issues and update mirrors"
echo

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)"
   exit 1
fi

# Backup current keyring
echo "1. Backing up current keyring..."
mkdir -p /root/keyring-backup-$(date +%Y%m%d-%H%M%S)
cp -r /etc/pacman.d/gnupg /root/keyring-backup-$(date +%Y%m%d-%H%M%S)/ 2>/dev/null || true

# Remove corrupted keyring
echo "2. Removing corrupted keyring..."
rm -rf /etc/pacman.d/gnupg

# Initialize new keyring
echo "3. Initializing new keyring..."
pacman-key --init

# Populate with Artix keys
echo "4. Populating with Artix keys..."
pacman-key --populate artix

# Add Arch keys (needed for some packages)
echo "5. Adding Arch Linux keys..."
pacman-key --populate archlinux

# Refresh and update keys
echo "6. Refreshing keyring..."
pacman-key --refresh-keys

# Fix any remaining key issues
echo "7. Fixing key trust levels..."
pacman-key --lsign-key 95AEC5D0C1E294FC9F82B253573C5E08A28C4665  # Artix master key
pacman-key --lsign-key 78E8D1F7398565E5  # Artix Build System

# Clear package cache to force fresh downloads
echo "8. Clearing package cache..."
pacman -Scc --noconfirm

# Update mirrorlist
echo "9. Updating mirrorlist..."
cp mirrorlist /etc/pacman.d/mirrorlist

# Test database synchronization
echo "10. Testing database synchronization..."
if pacman -Sy; then
    echo "✓ Keyring fix successful! Repositories are now accessible."
else
    echo "✗ Issues still persist. Check the troubleshooting script."
    exit 1
fi

echo
echo "=== Keyring fix completed successfully! ==="
echo "You can now run: pacman -Syu"
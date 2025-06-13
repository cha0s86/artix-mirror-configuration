#!/bin/bash

# Emergency Keyring Reset Script
# Use this if the main fix script doesn't work

set -e

echo "=== Emergency Artix Keyring Reset ==="
echo "WARNING: This will completely reset your keyring!"
echo

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)"
   exit 1
fi

read -p "Are you sure you want to proceed? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

echo "1. Stopping any running pacman processes..."
killall -9 pacman 2>/dev/null || true
killall -9 pacman-key 2>/dev/null || true

echo "2. Removing all keyring data..."
rm -rf /etc/pacman.d/gnupg/
rm -rf /root/.gnupg/

echo "3. Reinstalling artix-keyring package..."
# Download keyring package manually if needed
cd /tmp
curl -L -O https://mirror1.artixlinux.org/packages/system/artix-keyring-20240208-1-any.pkg.tar.zst || \
curl -L -O https://mirrors.dotsrc.org/artix-linux/packages/system/artix-keyring-20240208-1-any.pkg.tar.zst

# Install without signature verification
pacman -U --noconfirm *.pkg.tar.zst

echo "4. Initializing fresh keyring..."
pacman-key --init
pacman-key --populate artix archlinux

echo "5. Testing..."
pacman -Sy

echo "✓ Emergency keyring reset completed!"
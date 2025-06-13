#!/bin/bash

# Artix Linux Mirror Update Script
# This script updates the mirrorlist and tests mirror connectivity

echo "Updating Artix Linux mirrors..."

# Backup current mirrorlist
sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup

# Copy new mirrorlist
sudo cp mirrorlist /etc/pacman.d/mirrorlist

# Update pacman configuration if needed
if [ -f "pacman.conf" ]; then
    sudo cp /etc/pacman.conf /etc/pacman.conf.backup
    sudo cp pacman.conf /etc/pacman.conf
fi

# Update package database with new mirrors
echo "Updating package databases..."
sudo pacman -Sy

# Test if databases are accessible
echo "Testing repository accessibility..."

repos=("system" "world" "galaxy" "extra" "community")

for repo in "${repos[@]}"; do
    echo -n "Testing $repo repository... "
    if pacman -Sl $repo > /dev/null 2>&1; then
        echo "OK"
    else
        echo "FAILED"
    fi
done

echo "Mirror update complete!"
echo "If issues persist, try running: sudo pacman -Syy --force"
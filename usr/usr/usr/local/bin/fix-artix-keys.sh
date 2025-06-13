#!/bin/bash

# Artix Linux Keyring Fix Script
# Comprehensive key management and synchronization

set -e

# Ensure script is run with root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Function to handle key synchronization
sync_keys() {
    echo "Synchronizing Artix Linux keys..."
    pacman-key --init
    pacman-key --populate artix
    pacman-key --refresh-keys
}

# Function to clean up old or problematic keys
clean_keys() {
    echo "Cleaning up problematic keys..."
    pacman-key --delete-keys $(pacman-key -l | grep -E 'expired|disabled' | awk '{print $1}')
}

# Main key fixing process
main() {
    clean_keys
    sync_keys
    
    echo "Key synchronization completed successfully."
}

# Execute main function
main
  
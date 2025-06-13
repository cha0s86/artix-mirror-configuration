#!/bin/bash

# Artix Keyring Status Checker
# This script checks the current state of your keyring

echo "=== Artix Keyring Status Check ==="
echo

# Check if keyring directory exists
if [[ ! -d /etc/pacman.d/gnupg ]]; then
    echo "❌ Keyring directory missing! Run the fix script."
    exit 1
fi

# Check key count
key_count=$(pacman-key --list-keys 2>/dev/null | grep -c "^pub" || echo "0")
echo "📊 Total keys in keyring: $key_count"

if [[ $key_count -gt 200 ]]; then
    echo "⚠️  WARNING: Too many keys ($key_count)! This can cause issues."
    echo "   Consider running the keyring reset script."
fi

# Check for Artix master key
echo "🔑 Checking for Artix master key..."
if pacman-key --list-keys | grep -q "95AEC5D0C1E294FC9F82B253573C5E08A28C4665"; then
    echo "✓ Artix master key found"
else
    echo "❌ Artix master key missing!"
fi

# Check for Arch keys
echo "🔑 Checking for Arch master keys..."
arch_keys=0
if pacman-key --list-keys | grep -q "9741E8AC"; then
    ((arch_keys++))
fi
if pacman-key --list-keys | grep -q "684148BB"; then
    ((arch_keys++))
fi
echo "✓ Arch master keys found: $arch_keys/2"

# Test repository access
echo
echo "🌐 Testing repository access..."
for repo in system world galaxy extra community multilib; do
    echo -n "   $repo: "
    if curl -s --connect-timeout 5 https://mirror1.artixlinux.org/$repo/os/x86_64/${repo}.db >/dev/null 2>&1; then
        echo "✓"
    else
        echo "❌"
    fi
done

echo
echo "=== Status check completed ==="
echo "If you see issues above, run: sudo ./fix-artix-keys.sh"
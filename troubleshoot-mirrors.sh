#!/bin/bash

# Artix Linux Mirror Troubleshooting Script

echo "=== Artix Linux Mirror Troubleshooting ==="
echo

# Check current mirrorlist
echo "1. Checking current mirrorlist..."
if [ -f "/etc/pacman.d/mirrorlist" ]; then
    echo "Current active mirrors:"
    grep -E "^Server" /etc/pacman.d/mirrorlist | head -5
else
    echo "ERROR: No mirrorlist found!"
fi
echo

# Test mirror connectivity
echo "2. Testing mirror connectivity..."
test_mirrors() {
    local mirrors=(
        "https://mirror1.artixlinux.org/repos"
        "https://artixlinux.org/repos"
        "https://mirrors.ocf.berkeley.edu/artix-linux/repos"
        "https://mirror.leaseweb.com/artix/repos"
        "https://mirror.pascalpuffke.de/artix-linux/repos"
    )
    
    for mirror in "${mirrors[@]}"; do
        echo -n "Testing $mirror... "
        if curl -s --connect-timeout 5 "$mirror/system/os/x86_64/" > /dev/null; then
            echo "OK"
        else
            echo "FAILED"
        fi
    done
}

test_mirrors
echo

# Check pacman configuration
echo "3. Checking pacman configuration..."
if grep -q "\[extra\]" /etc/pacman.conf; then
    echo "✓ extra repository is configured"
else
    echo "✗ extra repository is missing from pacman.conf"
fi

if grep -q "\[community\]" /etc/pacman.conf; then
    echo "✓ community repository is configured"
else
    echo "✗ community repository is missing from pacman.conf"
fi
echo

# Check database files
echo "4. Checking database files..."
db_path="/var/lib/pacman/sync"
repos=("system" "world" "galaxy" "extra" "community")

for repo in "${repos[@]}"; do
    if [ -f "$db_path/$repo.db" ]; then
        echo "✓ $repo.db exists ($(stat -c%s "$db_path/$repo.db" | numfmt --to=iec))"
    else
        echo "✗ $repo.db missing"
    fi
done
echo

# Suggested fixes
echo "5. Suggested fixes:"
echo "   a) Force refresh databases: sudo pacman -Syy"
echo "   b) Clear package cache: sudo pacman -Scc"
echo "   c) Reset keyrings: sudo pacman-key --refresh-keys"
echo "   d) Reinstall keyring: sudo pacman -S artix-keyring --force"
echo "   e) Use alternative mirror manually:"
echo "      sudo pacman -Sy --config <(echo '[extra]'; echo 'Server = https://mirrors.ocf.berkeley.edu/artix-linux/repos/\$repo/os/\$arch')"
echo

echo "=== End of troubleshooting ==="
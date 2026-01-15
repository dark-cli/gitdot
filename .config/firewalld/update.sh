#!/bin/bash
# Update firewalld configuration from ~/.config/firewalld
# Copies zones and policies to system directories and reloads

set -e

echo "🔥 Updating firewalld configuration..."

# Copy zones
if ls ~/.config/firewalld/zones/*.xml 1>/dev/null 2>&1; then
    echo "📁 Copying zones..."
    sudo cp ~/.config/firewalld/zones/*.xml /etc/firewalld/zones/
fi

# Copy policies
if ls ~/.config/firewalld/policies/*.xml 1>/dev/null 2>&1; then
    echo "📁 Copying policies..."
    sudo mkdir -p /etc/firewalld/policies
    sudo cp ~/.config/firewalld/policies/*.xml /etc/firewalld/policies/
fi

# Reload
echo "🔄 Reloading firewall..."
sudo firewall-cmd --reload

echo ""
echo "✅ Done!"
echo ""
echo "Active zones:"
sudo firewall-cmd --get-active-zones
echo ""
echo "Active policies:"
sudo firewall-cmd --get-policies

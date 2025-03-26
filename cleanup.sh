#!/bin/bash

# Exit if any command fails
set -e

echo " Starting Netdata cleanup..."

# Stop Netdata service
echo " Stopping Netdata service..."
sudo systemctl stop netdata || true
sudo systemctl disable netdata || true

# Remove Netdata directories
echo "🗑 Removing Netdata files and directories..."
sudo rm -rf /etc/netdata /var/lib/netdata /usr/lib/netdata /var/log/netdata

# Remove Netdata user and group
echo " Removing Netdata user and group..."
sudo userdel netdata || true
sudo groupdel netdata || true

# Remove Netdata binary
echo " Removing Netdata executable..."
sudo rm -f /usr/sbin/netdata

# Remove Netdata dependencies (optional)
echo " Uninstalling dependencies..."
if command -v apt &> /dev/null; then
    sudo apt remove --purge -y netdata
    sudo apt autoremove -y
elif command -v yum &> /dev/null; then
    sudo yum remove -y netdata
    sudo yum autoremove -y
else
    echo " Skipping dependency removal (unsupported package manager)."
fi

# Close firewall ports (if applicable)
if command -v ufw &> /dev/null; then
    echo " Closing Netdata port in UFW..."
    sudo ufw deny 19999/tcp || true
fi

if command -v firewall-cmd &> /dev/null; then
    echo " Closing Netdata port in firewalld..."
    sudo firewall-cmd --permanent --remove-port=19999/tcp || true
    sudo firewall-cmd --reload || true
fi

echo " Netdata has been completely removed!"
exit 0

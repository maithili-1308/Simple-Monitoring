#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo " Starting Netdata installation..."

# Update system package lists
echo " Updating package lists..."
sudo apt update -y || sudo yum update -y

# Install required dependencies
echo " Installing required dependencies..."
sudo apt install -y curl wget git || sudo yum install -y curl wget git

# Download and run the Netdata installer
echo " Downloading and installing Netdata..."
bash <(curl -Ss https://my-netdata.io/kickstart.sh) --stable-channel

# Enable and start Netdata service
echo " Enabling and starting Netdata..."
sudo systemctl enable netdata
sudo systemctl start netdata

# Open firewall port (if using UFW or firewalld)
if command -v ufw &> /dev/null; then
    echo " Allowing Netdata through UFW..."
    sudo ufw allow 19999/tcp
fi

if command -v firewall-cmd &> /dev/null; then
    echo " Allowing Netdata through firewalld..."
    sudo firewall-cmd --permanent --add-port=19999/tcp
    sudo firewall-cmd --reload
fi

# Display Netdata access information
IP_ADDRESS=$(hostname -I | awk '{print $1}')
echo " Netdata installation complete!"
echo " Access Netdata at: http://$IP_ADDRESS:19999/"

exit 0

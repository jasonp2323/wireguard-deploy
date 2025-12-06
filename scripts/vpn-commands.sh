#!/bin/bash

# Log start of script
echo "Starting vpn-commands.sh script..."

# Retrieve package lists and upgrade packages
echo "Updating package lists..."
sudo apt-get update
echo "Package Lists Updated."

echo "Upgrading packages..."
sudo apt-get upgrade -y
echo "All Packages Upgraded."

# Install WireGuard
echo "Installing WireGuard..."
sudo apt-get install wireguard -y
echo "WireGaurd Installation Completed."

# Generate private and public keys
echo "Generating keys..."
wg genkey | tee privatekey | wg pubkey > publickey
echo "Keys Generated."

# Generate WireGuard configuration file
echo "Creating WireGuard configuration file..."
sudo bash -c 'cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
PrivateKey = $(cat privatekey)
Address = 10.11.0.1/24
SaveConfig=true
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o enX0 -j MASQUERADE;
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o enX0 -j MASQUERADE;
ListenPort = 51820
EOF'
echo "Coniguration file created."

# Start WireGuard interface
echo "Starting WireGuard service..."
wg-quick up wg0
echo "WireGaurd service started."

# Check WireGuard status
echo "Checking WireGuard status..."
sudo wg

# Enable IP forwarding
echo "Enabling IP forwarding..."
sudo sysctl -w net.ipv4.ip_forward=1

# Add Dynamic DNS cronjob
(crontab -l 2>/dev/null; echo "*/5 * * * * /usr/bin/python3 /home/ubuntu/scripts/dynamic-dns/update-dns.py") | crontab -

# Run Dnymic DNS script 1st time
/usr/bin/python3 /home/ubuntu/scripts/dynamic-dns/update-dns.py

# Log end of script
echo "vpn-commands.sh script completed."
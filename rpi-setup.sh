#!/bin/bash

# Remove raspi-config.
sudo apt remove raspi-config -y

# Set password.
echo "pi:IMnotBNcrE8ive" | sudo chpasswd

# Set timezone.
sudo rm -f /etc/localtime
sudo ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime

# Setup wifi.
touch wpa_supplicant.conf
echo "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev" >> wpa_supplicant.conf
echo "update_config=1" >> wpa_supplicant.conf
echo "country=US" >> wpa_supplicant.conf
echo -e "network=\n{\nssid=\"ATT3tf4ur4\"\npsk=\"H3nrB1wan9n3t\"}" >> wpa_supplicant.conf
sudo mv -f wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf

# Setup SSH server.
sudo systemctl enable ssh
sudo systemctl start ssh

# Update existing system.
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

# Install .NET Core
sudo apt install libunwind8 gettext -y
wget https://download.visualstudio.microsoft.com/download/pr/f9c95fa6-0fa0-4fa5-b6f2-e782b4044b76/42cd3637fb99a9ffde1469ef936be0c3/dotnet-runtime-3.1.4-linux-arm.tar.gz -O dotnet.tar.gz
sudo mkdir -p /opt/dotnet
sudo tar zxf <archive>.tar.gz -C /opt/dotnet
sudo ln -s /opt/dotnet/dotnet /usr/local/bin
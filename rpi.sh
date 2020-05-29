#!/bin/bash

cd ~

### CONFIG
# Root username.
touch hostname
echo "antlu" >> hostname
sudo mv -f hostname /etc/hostname

# Root password.
#echo "antlu:IMnotBNcrE8ive" | sudo chpasswd

# Timezone.
sudo rm -f /etc/localtime
sudo ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime

# Keyboard Layout.
touch keyboard
echo -e "XKBMODEL=\"pc105\"\n" >> keyboard
echo -e "XKBLAYOUT=\"us\"" >> keyboard
echo -e "XKBVARIANT=\"\"" >> keyboard
echo -e "XKBOPTIONS=\"\"" >> keyboard
echo -e "\nBACKSPACE=\"guess\"" >> keyboard
sudo mv -f keyboard /etc/default/keyboard

# Wifi.
touch wpa_supplicant.conf
echo "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev" >> wpa_supplicant.conf
echo "update_config=1" >> wpa_supplicant.conf
echo "country=US" >> wpa_supplicant.conf
echo -e "network=\n{\nssid=\"ATT3tf4ur4\"\npsk=\"H3nrB1wan9n3t\"\n}" >> wpa_supplicant.conf
sudo mv -f wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf

# SSH Server.
sudo systemctl enable ssh
sudo systemctl start ssh



### SOFTWARE
# Update existing system.
sudo apt update
sudo apt upgrade -y

# Remove raspi-config.
sudo apt remove raspi-config -y &> /dev/null

# Install net-tools.
sudo apt install net-tools

# Install .NET Core 3.1.4 Runtime
sudo apt install libunwind8 gettext -y
#wget https://download.visualstudio.microsoft.com/download/pr/f9c95fa6-0fa0-4fa5-b6f2-e782b4044b76/42cd3637fb99a9ffde1469ef936be0c3/dotnet-runtime-3.1.4-linux-arm.tar.gz -O dotnet.tar.gz
curl -o dotnet_3.1.4.tar.gz https://download.visualstudio.microsoft.com/download/pr/da94a32f-8fa7-4df8-b54c-f3442dc2a17a/0badd31a0487b0318a3234baf023aa3c/dotnet-runtime-3.1.4-linux-arm64.tar.gz
sha512sum dotnet_3.1.4.tar.gz > dotnet_3.1.4.tar.gz.sha512
sha512sum -c dotnet_3.1.4.tar.gz.sha512
rm dotnet_3.1.4.tar.gz.sha512
sudo mkdir -p /opt/dotnet
sudo tar zxf dotnet_3.1.4.tar.gz -C /opt/dotnet
sudo ln -s /opt/dotnet/dotnet /usr/local/bin
rm dotnet_3.1.4.tar.gz

# Cleanup.
sudo apt autoremove -y
sudo reboot

### END.
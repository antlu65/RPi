#!/bin/bash
echo -e "\n***** RASPBERRY PI CONFIGURATOR SCRIPT *****"
echo -e "\n[BEGIN] Let's begin!"
cd ~

### SETUP
echo -e "\n[TASK] Updating and upgrading packages..."
# update+upgrade existing packages.
	sudo killall apt -q
	sudo rm /var/lib/apt/lists/lock /var/cache/apt/archives/lock /var/lib/dpkg/lock* 2> /dev/null
	sudo dpkg --configure -a
	sudo apt update upgrade -y 2> /dev/null
echo -e "[OK]\n"



### USER SETTINGS
# config timezone.
echo -e "\n[TASK] Configuring timezone, keyboard...\n"
	sudo rm -f /etc/localtime
	sudo ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
# config keyboard layout.
	touch keyboard
	echo -e "XKBMODEL=\"pc105\"\n" >> keyboard
	echo -e "XKBLAYOUT=\"us\"" >> keyboard
	echo -e "XKBVARIANT=\"\"" >> keyboard
	echo -e "XKBOPTIONS=\"\"" >> keyboard
	echo -e "\nBACKSPACE=\"guess\"" >> keyboard
	sudo mv -f keyboard /etc/default/keyboard
echo -e "[OK]\n"



### NETWORK/INTERFACING
# config ssh.
echo -e "\n[START] Configuring ssh...\n"
	sudo systemctl enable ssh
	sudo systemctl start ssh
echo -e "[OK]\n"
# install net-tools, wireless-tools
	sudo apt install net-tools wireless-tools -y
# config wifi.
echo -e "\n[START] Configuring wifi...\n"
	touch wpa_supplicant.conf
	echo "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev" >> wpa_supplicant.conf
	echo "update_config=1" >> wpa_supplicant.conf
	echo "country=US" >> wpa_supplicant.conf
	echo -e "network=\n{\nssid=\"ATT3tf4ur4\"\npsk=\"H3nrB1wan9n3t\"\n}" >> wpa_supplicant.conf
	sudo mv -f wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf
	ifconfig wlan0 up
	#sudo dhclient wlan0
echo -e "[OK]\n"



### .NET CORE RUNTIMES
echo -e "\n[START] Installing .NET Core runtimes...\n"
# install dependencies.
	sudo apt install libunwind8 gettext -y
# install dotnet_3.1.4.
	curl -o dotnet_3.1.4.tar.gz https://download.visualstudio.microsoft.com/download/pr/da94a32f-8fa7-4df8-b54c-f3442dc2a17a/0badd31a0487b0318a3234baf023aa3c/dotnet-runtime-3.1.4-linux-arm64.tar.gz
	sha512sum dotnet_3.1.4.tar.gz > dotnet_3.1.4.tar.gz.sha512
	sha512sum -c dotnet_3.1.4.tar.gz.sha512
	rm dotnet_3.1.4.tar.gz.sha512
	sudo mkdir -p /opt/dotnet
	sudo tar zxf dotnet_3.1.4.tar.gz -C /opt/dotnet
	rm dotnet_3.1.4.tar.gz
# create link.
	sudo ln -s /opt/dotnet/dotnet /usr/local/bin
# install dotnet_5.
	curl -o dotnet_5.tar.gz https://download.visualstudio.microsoft.com/download/pr/d122c932-67f1-4358-9bdb-64cce009ee27/0a46b82fcb16e952491385149896ccda/dotnet-runtime-5.0.0-preview.4.20251.6-linux-arm64.tar.gz
	sha512sum dotnet_5.tar.gz > dotnet_5.tar.gz.sha512
	sha512sum -c dotnet_5.tar.gz.sha512
	rm dotnet_5.tar.gz.sha512
	sudo tar zxf dotnet_5.tar.gz -C /opt/dotnet
echo -e "[OK]\n"



### CLEANUP
echo -e "\n[START] Cleaning up..."
# remove unnecessary packages.
	sudo apt remove raspi-config -y &> /dev/null
	sudo apt autoremove -y
echo -e "[OK]\n"



### END.
echo -e "[END] All done!\n"
echo -e "#################"
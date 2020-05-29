#!/bin/bash
echo -e "\n ***** [BEGIN] Setting up Raspberry Pi..."



### SETUP
# timezone, keyboard, ssh
echo -e "\n --- [TASK] Configuring timezone..."
	sudo rm -f /etc/localtime
	sudo ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
echo -e " --- [OK]\n"
echo -e "\n --- [TASK] Configuring keyboard..."
	kbconfig=./shared/keyboard
	sudo mv -f $kbconfig /etc/default/keyboard
echo -e " --- [OK]\n"
echo -e "\n --- [TASK] Configuring ssh..."
	sudo systemctl enable ssh
	sudo systemctl start ssh
echo -e " --- [OK]\n"



# INSTALL
# update/upgrade default software
echo -e "\n --- [TASK] Updating default packages..."
	sudo killall apt -q
	sudo rm /var/lib/apt/lists/lock /var/cache/apt/archives/lock /var/lib/dpkg/lock* 2> /dev/null
	sudo dpkg --configure -a
	sudo apt update
	sudo apt upgrade -y
echo -e " --- [OK]\n"
# netcore
echo -e "\n --- [TASK] Installing .NET Core runtimes..."
	sudo apt install libunwind8 gettext -y
	# install dotnet_3.1.4.
	curl -o dotnet_3.1.4.tar.gz https://download.visualstudio.microsoft.com/download/pr/da94a32f-8fa7-4df8-b54c-f3442dc2a17a/0badd31a0487b0318a3234baf023aa3c/dotnet-runtime-3.1.4-linux-arm64.tar.gz
	sha512sum dotnet_3.1.4.tar.gz > dotnet_3.1.4.tar.gz.sha512
	sha512sum -c dotnet_3.1.4.tar.gz.sha512
	sudo mkdir -p /opt/dotnet
	sudo tar zxf dotnet_3.1.4.tar.gz -C /opt/dotnet
	rm dotnet_3.1.4.tar.gz dotnet_3.1.4.tar.gz.sha512
	# create link.
	sudo ln -s /opt/dotnet/dotnet /usr/local/bin
	# install dotnet_5.
	curl -o dotnet_5.tar.gz https://download.visualstudio.microsoft.com/download/pr/d122c932-67f1-4358-9bdb-64cce009ee27/0a46b82fcb16e952491385149896ccda/dotnet-runtime-5.0.0-preview.4.20251.6-linux-arm64.tar.gz
	sha512sum dotnet_5.tar.gz > dotnet_5.tar.gz.sha512
	sha512sum -c dotnet_5.tar.gz.sha512
	sudo tar zxf dotnet_5.tar.gz -C /opt/dotnet
	rm dotnet_5.tar.gz dotnet_5.tar.gz.sha512
echo -e " --- [OK]\n"



# networking/wifi
echo -e "\n --- [TASK] Configuring networking..."
	sudo apt install net-tools wireless-tools wpasupplicant -y
	network="ATT3tf4ur4"
	netpass="H3nrB1wan9n3t"
	#sudo ifconfig wlan0 up
	wpa_passphrase "$network" "$netpass" | tee wpa_supplicant.conf &> /dev/null	
	# echo "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev" >> wpa_supplicant.conf
	# echo "update_config=1" >> wpa_supplicant.conf
	# echo "country=US" >> wpa_supplicant.conf
	# echo -e "network=\n{\nssid=\"ATT3tf4ur4\"\npsk=\"H3nrB1wan9n3t\"\n}" >> wpa_supplicant.conf
	sudo mv -f wpa_supplicant.conf /etc/wpa_supplicant.conf
echo -e " --- [OK]\n"



### CLEANUP
echo -e "\n --- [TASK] Cleaning up..."
	sudo apt remove raspi-config
	sudo apt autoremove -y
echo -e " --- [OK]\n"
echo -e " ----- [END] Raspberry Pi setup complete. Rebooting..."
sleep 5
sudo reboot
### END.
#!/bin/bash
echo -e "\n ***** [BEGIN] Configuring Raspberry Pi OS (32bit)..."



### SETUP
# password, timezone, keyboard, ssh
echo -e "\n --- [TASK] Configuring password..."
	user=pi
	pass=IMnotBNcrE8ive
	echo "$user:$pass" | sudo chpasswd
echo -e " --- [OK]\n"
echo -e "\n --- [TASK] Configuring timezone..."
	sudo rm -f /etc/localtime
	sudo ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
echo -e " --- [OK]\n"
echo -e "\n --- [TASK] Configuring keyboard..."
	kbconfig="keyboard"
	touch $kbconfig
	cat <<- EOF > $kbconfig
	XKBMODEL="pc105"
	XKBLAYOUT="us"
	XKBVARIANT=""
	XKBOPTIONS=""
	BACKSPACE="guess"
EOF
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
	curl -o dotnet_3.1.4.tar.gz https://download.visualstudio.microsoft.com/download/pr/f9c95fa6-0fa0-4fa5-b6f2-e782b4044b76/42cd3637fb99a9ffde1469ef936be0c3/dotnet-runtime-3.1.4-linux-arm.tar.gz
	sha512sum dotnet_3.1.4.tar.gz > dotnet_3.1.4.tar.gz.sha512
	sha512sum -c dotnet_3.1.4.tar.gz.sha512
	sudo mkdir -p /opt/dotnet
	sudo tar zxf dotnet_3.1.4.tar.gz -C /opt/dotnet
	rm dotnet_3.1.4.tar.gz dotnet_3.1.4.tar.gz.sha512
	# install dotnet_5.
	curl -o dotnet_5.tar.gz https://download.visualstudio.microsoft.com/download/pr/fecfc81f-44c7-41f0-a158-894ca434876c/28cba3884db133373305a03a48f01eeb/dotnet-runtime-5.0.0-preview.4.20251.6-linux-arm.tar.gz
	sha512sum dotnet_5.tar.gz > dotnet_5.tar.gz.sha512
	sha512sum -c dotnet_5.tar.gz.sha512
	sudo tar zxf dotnet_5.tar.gz -C /opt/dotnet
	rm dotnet_5.tar.gz dotnet_5.tar.gz.sha512
	# create link.
	sudo rm /usr/local/bin/dotnet
	sudo ln -s /opt/dotnet/dotnet /usr/local/bin
echo -e " --- [OK]\n"



# networking/wifi
echo -e "\n --- [TASK] Configuring networking..."
	sudo apt install net-tools wireless-tools wpasupplicant -y
	network="ATT3tf4ur4"
	netpass="H3nrB1wan9n3t"
	netconfig="wpa_supplicant.conf"	
	cat <<- EOF > $netconfig
	ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
	update_config=1
	country=US
EOF
	wpa_passphrase "$network" "$netpass" > $netconfig
	sudo mv -f $netconfig /etc/$netconfig
echo -e " --- [OK]\n"



### CLEANUP
echo -e "\n --- [TASK] Cleaning up..."
	sudo apt remove raspi-config -y
	sudo apt autoremove -y
echo -e " --- [OK]\n"
echo -e " ----- [END] Raspberry Pi setup complete. Rebooting..."
sleep 5
sudo reboot
### END.
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
echo -e "\n --- [TASK] Configuring locale..."
	lconfig="locale"
	touch $lconfig
	cat <<- EOF > $lconfig
	LANG=en_US.UTF-8
EOF
	sudo mv -f $lconfig /etc/default/$lconfig
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
	sudo mv -f $kbconfig /etc/default/$kbconfig
echo -e " --- [OK]\n"
echo -e "\n --- [TASK] Configuring terminal login..."
	tconfig=override.conf
	tdir="/etc/systemd/system/getty@tty1.service.d"
	rootusername=pi
	cat <<-EOF > $tconfig
	[Service]
	ExecStart=
	ExecStart=/sbin/agetty --noissue --autologin $rootusername %I $TERM
EOF
	sudo mkdir $tdir
	sudo mv -f $tconfig "$tdir/$tconfig"
echo -e " --- [OK]\n"
echo -e "\n --- [TASK] Configuring ssh..."
	sudo systemctl enable ssh
	sudo systemctl start ssh
echo -e " --- [OK]\n"



echo -e "\n --- [TASK] Removing auto-update services..."
	echo "Disabling apt-daily.timer, apt-daily-upgrade.timer..."
	sudo systemctl --now disable apt-daily.timer apt-daily-upgrade.timer
	echo "Disabling unattended-upgrades.service, apt-daily.service, apt-daily-upgrade.service..."
	sudo systemctl --now disable apt-daily apt-daily-upgrade
	sudo systemctl --now kill apt-daily apt-daily-upgrade
	echo "Daemon reload..."
	sudo systemctl daemon-reload
	sleep 3
	echo "Deleting locks..."
	sudo rm /var/lib/apt/lists/lock /var/cache/apt/archives/lock /var/lib/dpkg/lock* 2> /dev/null
	sleep 3
	echo "Configure dpkg..."
	sudo dpkg --configure -a
	sleep 3
echo -e " --- [OK]\n"
# INSTALL
# update/upgrade default software
echo -e "\n --- [TASK] Updating default packages..."
	sudo apt update
	sudo apt upgrade -y
echo -e " --- [OK]\n"
# netcore
echo -e "\n --- [TASK] Installing .NET Core runtimes..."
	sudo apt install libunwind8 gettext -y
	# install dotnet_3.1.8.
	curl -o dotnet_3.1.8.tar.gz https://download.visualstudio.microsoft.com/download/pr/3f331a87-d2e9-46c1-b7ef-369f8540e966/2e534214982575ee3c79a9ce9f9a4483/dotnet-runtime-3.1.8-linux-arm.tar.gz
	sha512sum dotnet_3.1.8.tar.gz > dotnet_3.1.8.tar.gz.sha512
	sha512sum -c dotnet_3.1.8.tar.gz.sha512
	sudo mkdir -p /opt/dotnet
	sudo tar zxf dotnet_3.1.8.tar.gz -C /opt/dotnet
	rm dotnet_3.1.8.tar.gz dotnet_3.1.8.tar.gz.sha512
	# install dotnet_5-rc1.
	curl -o dotnet_5-rc1.tar.gz https://download.visualstudio.microsoft.com/download/pr/de043fe1-1a5b-4d29-878c-87a99efcca8d/8c928e7725179e4707975a13fc01d8ed/dotnet-runtime-5.0.0-rc.1.20451.14-linux-arm.tar.gz
	sha512sum dotnet_5-rc1.tar.gz > dotnet_5-rc1.tar.gz.sha512
	sha512sum -c dotnet_5-rc1.tar.gz.sha512
	sudo tar zxf dotnet_5-rc1.tar.gz -C /opt/dotnet
	rm dotnet_5-rc1.tar.gz dotnet_5-rc1.tar.gz.sha512
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
	wpa_passphrase "$network" "$netpass" >> $netconfig
	sudo mv -f $netconfig /etc/wpa_supplicant/$netconfig
	rfkill unblock wifi
	sudo ifconfig wlan0 up
	sudo dhclient wlan0 &
echo -e " --- [OK]\n"



### CLEANUP
echo -e "\n --- [TASK] Cleaning up..."
	sudo apt remove raspi-config -y
	sudo apt autoremove -y
echo -e " --- [OK]\n"
echo -e " ----- [END] Raspberry Pi OS (32bit) setup complete. Rebooting..."
sleep 5
sudo reboot
### END.
#!/bin/bash
echo -e "\n ***** [BEGIN] Configuring Ubuntu Server (64bit)..."


echo -e "\n --- [TASK] Stopping service: unattended-upgrades..."
	sudo systemctl stop unattended-upgrades
	sudo systemctl kill unattended-upgrades
echo -e " --- [OK]\n"


### SETUP
# hostname
echo -e "\n --- [TASK] Configuring hostname..."
	hostname=$(sed -n 1p /etc/hostname)
	# incase we previously added hostname to 'hosts' file, remove it first.
	# save copy of 'hosts' file for us to edit.
	sed "1s/$hostname//" /etc/hosts > hosts
	#sed '1s/'$hostname'/ /' /etc/hosts > hosts
	# append hostname to end of first line
	newline="$(sed -n 1p hosts) $hostname"
	newcommand="1c\\$newline"
	sed "$newcommand" /etc/hosts > hosts
	sudo mv -f hosts /etc/hosts
echo -e " --- [OK]\n"
# timezone, keyboard, ssh
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
	curl -o dotnet_3.1.4.tar.gz https://download.visualstudio.microsoft.com/download/pr/da94a32f-8fa7-4df8-b54c-f3442dc2a17a/0badd31a0487b0318a3234baf023aa3c/dotnet-runtime-3.1.4-linux-arm64.tar.gz
	sha512sum dotnet_3.1.4.tar.gz > dotnet_3.1.4.tar.gz.sha512
	sha512sum -c dotnet_3.1.4.tar.gz.sha512
	sudo mkdir -p /opt/dotnet
	sudo tar zxf dotnet_3.1.4.tar.gz -C /opt/dotnet
	rm dotnet_3.1.4.tar.gz dotnet_3.1.4.tar.gz.sha512
	# install dotnet_5.
	curl -o dotnet_5.tar.gz https://download.visualstudio.microsoft.com/download/pr/d122c932-67f1-4358-9bdb-64cce009ee27/0a46b82fcb16e952491385149896ccda/dotnet-runtime-5.0.0-preview.4.20251.6-linux-arm64.tar.gz
	sha512sum dotnet_5.tar.gz > dotnet_5.tar.gz.sha512
	sha512sum -c dotnet_5.tar.gz.sha512
	sudo tar zxf dotnet_5.tar.gz -C /opt/dotnet
	rm dotnet_5.tar.gz dotnet_5.tar.gz.sha512
	# create link.
	sudo rm /usr/local/bin/dotnet &> /dev/null
	sudo ln -s /opt/dotnet/dotnet /usr/local/bin
echo -e " --- [OK]\n"



# networking/wifi
echo -e "\n --- [TASK] Configuring networking..."
	sudo apt install net-tools wireless-tools wpasupplicant -y
	netconfig="50-cloud-init.yaml"
	cat <<- EOF > $netconfig
network:
    version: 2
    ethernets:
        eth0:
            optional: true
            dhcp4: true
    wifis:
        wlan0:
            optional: true
            access-points:
                "ATT3tf4ur4":
                    password: "H3nrB1wan9n3t"
            dhcp4: true
EOF
	sudo mv -f $netconfig /etc/netplan/$netconfig
	sudo netplan --debug generate
	sudo netplan --debug apply
echo -e " --- [OK]\n"



### CLEANUP
echo -e "\n --- [TASK] Cleaning up..."
	sudo apt remove unattended-upgrades -y
	sudo apt autoremove -y
echo -e " --- [OK]\n"
echo -e " ----- [END] Ubuntu Server (64bit) setup complete. Rebooting..."
sleep 5
sudo reboot
### END.
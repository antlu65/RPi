#!/bin/bash
echo -e "\n ***** [BEGIN] Configuring Ubuntu Server (64bit)..."


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
echo -e "\n --- [TASK] Setup terminal auto-login..."
	touch override.conf
	cat <<-EOF > override.conf
	[Service]
	ExecStart=
	ExecStart=/sbin/agetty --noissue --autologin ubuntu %I $TERM
EOF
	folder="/etc/systemd/system/getty@tty1.service.d"
	sudo mkdir $folder
	sudo mv -f override.conf "$folder/$override.conf"
echo -e " --- [OK]\n"



# INSTALL
echo -e "\n --- [TASK] Removing auto-update services..."
	echo "Disabling apt-daily.timer, apt-daily-upgrade.timer..."
	sudo systemctl --now disable apt-daily.timer apt-daily-upgrade.timer
	echo "Disabling unattended-upgrades.service, apt-daily.service, apt-daily-upgrade.service..."
	sudo systemctl --now disable unattended-upgrades apt-daily apt-daily-upgrade
	sudo systemctl --now kill unattended-upgrades apt-daily apt-daily-upgrade
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
echo -e "\n --- [TASK] Updating default packages..."
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
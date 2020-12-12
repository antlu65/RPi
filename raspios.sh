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
echo -e "\n --- [TASK] Configuring i2c..."
  sudo -- bash -c 'echo "dtparam=i2c_arm=on" >> /boot/config.txt'
  sudo modprobe i2c-dev
  sudo -- bash -c 'echo "i2c-dev" >> /etc/modules'
echo -e " --- [OK]\n"

# Remove auto-update service.
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

# Configure wifi.
echo -e "\n --- [TASK] Configuring wifi..."
	sudo apt install net-tools wireless-tools wpasupplicant -y -qq
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


# Update default software.
echo -e "\n --- [TASK] Updating default packages..."
	sudo apt update -q
	sudo apt upgrade -y -q
echo -e " --- [OK]\n"

# Install .NET 5, .NET Core 3.1.
echo -e "\n --- [TASK] Installing .NET 5, .NET Core 3.1..."
	sudo apt install libunwind8 gettext -y -q
	# install dotnet_3.1.10.
	curl -o dotnet_3.1.10.tar.gz https://download.visualstudio.microsoft.com/download/pr/8261839b-2b61-4c49-a3e4-90b32f25bf50/12ff8ed47c32c199c04066eb07647f4e/dotnet-runtime-3.1.10-linux-arm.tar.gz
	sha512sum dotnet_3.1.10.tar.gz > dotnet_3.1.10.tar.gz.sha512
	sha512sum -c dotnet_3.1.10.tar.gz.sha512
	sudo mkdir -p /opt/dotnet
	sudo tar zxf dotnet_3.1.10.tar.gz -C /opt/dotnet
	rm dotnet_3.1.10.tar.gz dotnet_3.1.10.tar.gz.sha512
	# install dotnet_5.0.1.
	curl -o dotnet_5.0.1.tar.gz https://download.visualstudio.microsoft.com/download/pr/46b6dfbf-8da3-4e95-ae33-abd5c875bc3e/566db9b58e809f4ed6d571a1de09fc58/dotnet-runtime-5.0.1-linux-arm.tar.gz
	sha512sum dotnet_5.0.1.tar.gz > dotnet_5.0.1.tar.gz.sha512
	sha512sum -c dotnet_5.0.1.tar.gz.sha512
	sudo tar zxf dotnet_5.0.1.tar.gz -C /opt/dotnet
	rm dotnet_5.0.1.tar.gz dotnet_5.0.1.tar.gz.sha512
	# create link.
	sudo rm /usr/local/bin/dotnet
	sudo ln -s /opt/dotnet/dotnet /usr/local/bin
echo -e " --- [OK]\n"

# Install Prometheus.
echo -e "\n --- [TASK] Installing Prometheus..."
  sudo apt install prometheus -y -q
  sudo rm /etc/prometheus/prometheus.yml
  prconfig="prometheus.yml"
	touch $prconfig
	cat <<- EOF > $prconfig
	global:
	  scrape_interval: 5s
	  evaluation_interval: 15s
  
  rule_files:
  #
  
  scrape_configs:
    - job_name: prometheus
      static_configs:
        - targets: ['localhost:1234']
EOF
	sudo mv -f $prconfig /etc/prometheus/$kbconfig
echo -e " --- [OK]\n"

# Install Grafana.
echo -e "\n --- [TASK] Installing Grafana..."
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
sudo apt update -qq
sudo apt install grafana -y -q
echo -e " --- [OK]\n"


### CLEANUP
echo -e "\n --- [TASK] Cleaning up..."
	sudo apt remove raspi-config -y
	sudo apt autoremove -y
	rm raspios.sh
echo -e " --- [OK]\n"
echo -e " ----- [END] Raspberry Pi OS (32bit) setup complete. Rebooting..."
sleep 5
sudo reboot
### END.
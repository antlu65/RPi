#!/bin/bash
echo -e "\n ---***--- Raspberry Pi OS (32bit) Setup\n"

# Configure Password.
echo -e " -*- Configure Password ... "
	user=pi
	pass=IMnotBNcrE8ive
	echo "$user:$pass" | sudo chpasswd
echo -e " --- OK\n"


# Configure Timezone.
echo -e " -*- Configure Timezone ... "
	sudo rm -f /etc/localtime
	sudo ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
echo -e " --- OK\n"


# Configure Locale.
echo -e " -*- Configure Locale ... "
	lconfig="locale"
	touch $lconfig
	cat <<- EOF > $lconfig
LANG=en_US.UTF-8
EOF
	sudo mv -f $lconfig /etc/default/$lconfig
echo -e " --- OK\n"


# Configure Keyboard.
echo -e "-*- Configure Keyboard ... "
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
echo -e " --- OK\n"

# Configure Terminal.
echo -e "-*- Configure Terminal ... "
	tconfig=override.conf
	rootusername=pi
	cat <<-EOF > $tconfig
[Service]
ExecStart=
ExecStart=/sbin/agetty --noissue --autologin $rootusername %I $TERM
EOF
	sudo mv -f $tconfig /etc/systemd/system/getty@tty1.service.d/$tconfig
echo -e " --- OK\n"

# Enable I2c, Disable Bluetooth, Audio, Graphics
echo -e " -*- Enable Two Wire Interface, Disable Bluetooth, Audio, Graphics ... "
  	cat <<-EOF > config.txt
[all]
dtparam=i2c_arm=on
dtoverlay=disable-bt
EOF
  	sudo mv -f config.txt /boot/config.txt
echo -e " --- OK\n"

# Enable SSH.
echo -e " -*- Enable ssh ... "
	sudo systemctl enable ssh
	sudo systemctl start ssh
echo -e " --- OK\n"

# Remove Auto-Update Service.
echo -e " -*- Remove Auto-Update Service ... "
	sudo systemctl --now disable apt-daily.timer apt-daily-upgrade.timer
	sudo systemctl --now disable apt-daily apt-daily-upgrade
	sudo systemctl --now kill apt-daily apt-daily-upgrade
	sudo systemctl daemon-reload
	sleep 3
	sudo rm /var/lib/apt/lists/lock /var/cache/apt/archives/lock /var/lib/dpkg/lock*
	sleep 3
	sudo dpkg --configure -a
	sleep 3
echo -e " --- OK\n"

# Upgrade Default Packages.
echo -e " -*- Upgrade Default Packages ... "
	sudo apt update -q
	sudo apt upgrade -y -q
echo -e " --- OK\n"

# Setup Wifi.
echo -e " -*- Setup Wifi ... "
	sudo apt install net-tools wireless-tools wpasupplicant -y -q
	network="AutomatioCoreNet"
	netpass="ColonialHeavy3298671"
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
echo -e " --- OK\n"

# Install .NET 5, .NET Core 3.1.
echo -e " -*- Install Microsoft .NET ... "
	sudo apt install libunwind8 gettext -y -q
	sudo mkdir -p /opt/dotnet
	
	curl -o dotnet_5.0.4.tar.gz https://download.visualstudio.microsoft.com/download/pr/5a496e41-23da-4aaa-94a7-baa9ab619fc6/0d000727345f3f71858ee79367f6ec23/dotnet-runtime-5.0.4-linux-arm.tar.gz
	sha512sum dotnet_5.0.4.tar.gz > dotnet_5.0.4.tar.gz.sha512
	sha512sum -c dotnet_5.0.4.tar.gz.sha512
	sudo tar zxf dotnet_5.0.4.tar.gz -C /opt/dotnet
	rm dotnet_5.0.4.tar.gz dotnet_5.0.4.tar.gz.sha512
	
	curl -o dotnet_3.1.13.tar.gz https://download.visualstudio.microsoft.com/download/pr/7b53e04d-db64-4b97-af76-9da1a1567d94/e71e3d484accc5bb8db9e4f556d52cc9/dotnet-runtime-3.1.13-linux-arm.tar.gz
	sha512sum dotnet_3.1.13.tar.gz > dotnet_3.1.13.tar.gz.sha512
	sha512sum -c dotnet_3.1.13.tar.gz.sha512
	sudo tar zxf dotnet_3.1.13.tar.gz -C /opt/dotnet
	rm dotnet_3.1.13.tar.gz dotnet_3.1.13.tar.gz.sha512
	
	sudo rm /usr/local/bin/dotnet 2> /dev/null
	sudo ln -s /opt/dotnet/dotnet /usr/local/bin
echo -e " --- OK\n"

# Install Prometheus.
echo -e "-*- Install Prometheus ... "
  sudo apt install prometheus -y -q
  prconfig="prometheus.yml"
	touch $prconfig
	cat <<- EOF > $prconfig
global:
  scrape_interval: 5s
  evaluation_interval: 15s
scrape_configs:
  - job_name: prometheus
    static_configs:
    - targets: ['localhost:1234']
EOF
	sudo mv -f $prconfig /etc/prometheus/$prconfig
echo -e " --- OK\n"

# Install Grafana.
echo -e " -*- Install Grafana ... "
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
sudo apt update -q
sudo apt install grafana -y -q
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
echo -e " --- OK\n"


# Cleanup.
echo -e " -*- Cleanup ... "
	sudo apt remove raspi-config -y -q
	sudo apt autoremove -y -q
	rm raspios.sh
echo -e " --- OK\n"

# Reboot.
echo -e " ---***--- Setup Complete. Rebooting ... "
sleep 5
sudo shutdown -r now
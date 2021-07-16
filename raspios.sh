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
    network="AutoCoreNet"
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
    sudo apt install libncurses5 libunwind8 gettext -y -q
    sudo mkdir -p /opt/dotnet

    curl -o dotnet_5.0.8.tar.gz https://download.visualstudio.microsoft.com/download/pr/06f47628-7e59-4e2a-9002-72d7e11b8cde/79a68d8fc9812b4f94e4f9f32f3acbc8/dotnet-runtime-5.0.8-linux-arm.tar.gz
    sha512sum dotnet_5.0.8.tar.gz > dotnet_5.0.8.tar.gz.sha512
    sha512sum -c dotnet_5.0.8.tar.gz.sha512
    sudo tar zxf dotnet_5.0.8.tar.gz -C /opt/dotnet
    rm dotnet_5.0.8.tar.gz dotnet_5.0.8.tar.gz.sha512

    curl -o dotnet_3.1.17.tar.gz https://download.visualstudio.microsoft.com/download/pr/38a94860-f13c-4d7f-8089-4aaf6e34a4e0/d5dceff2f680b8ae9999de0028d64725/dotnet-runtime-3.1.17-linux-arm.tar.gz
    sha512sum dotnet_3.1.17.tar.gz > dotnet_3.1.17.tar.gz.sha512
    sha512sum -c dotnet_3.1.17.tar.gz.sha512
    sudo tar zxf dotnet_3.1.17.tar.gz -C /opt/dotnet
    rm dotnet_3.1.17.tar.gz dotnet_3.1.17.tar.gz.sha512

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
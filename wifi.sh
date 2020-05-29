#!/bin/bash
echo -e "\n ***** [BEGIN] Setting up Raspberry Pi..."

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
	kbconfig=./shared/keyboard
	sudo mv -f $kbconfig /etc/default/keyboard
echo -e " --- [OK]\n"
echo -e "\n --- [TASK] Configuring ssh..."
	sudo systemctl enable ssh
	sudo systemctl start ssh
echo -e " --- [OK]\n"

# update/upgrade default software
echo -e "\n --- [TASK] Updating default packages..."
	sudo killall apt -q
	sudo rm /var/lib/apt/lists/lock /var/cache/apt/archives/lock /var/lib/dpkg/lock* 2> /dev/null
	sudo dpkg --configure -a
	sudo apt update
	#sudo apt upgrade -y
echo -e " --- [OK]\n"

# networking/wifi
echo -e "\n --- [TASK] Configuring networking..."
	sudo apt install net-tools wireless-tools wpasupplicant -y
	npconfig=./ubuntu/50-cloud-init.yaml
	sudo mv -f $npconfig /etc/netplan/50-cloud-init.yaml
	sudo netplan generate
	sudo netplan apply
echo -e " --- [OK]\n"



### CLEANUP
echo -e "\n --- [TASK] Cleaning up..."
	sudo apt autoremove -y
echo -e " --- [OK]\n"
echo -e " ----- [END] Raspberry Pi setup complete. Rebooting..."
sleep 5
sudo reboot
### END.
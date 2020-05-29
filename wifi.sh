#!/bin/bash
echo -e "\n ***** [BEGIN] Setting up Raspberry Pi..."
cd ~

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
	touch keyboard
	echo -e "XKBMODEL=\"pc105\"\n" >> keyboard
	echo -e "XKBLAYOUT=\"us\"" >> keyboard
	echo -e "XKBVARIANT=\"\"" >> keyboard
	echo -e "XKBOPTIONS=\"\"" >> keyboard
	echo -e "\nBACKSPACE=\"guess\"" >> keyboard
	sudo mv -f keyboard /etc/default/keyboard
echo -e " --- [OK]\n"
echo -e "\n --- [TASK] Configuring ssh..."
	sudo systemctl enable ssh
	sudo systemctl start ssh
echo -e " --- [OK]\n"

# update/upgrade default software
echo -e "\n --- [TASK] Updating and upgrading default software..."
	sudo killall apt -q
	sudo rm /var/lib/apt/lists/lock /var/cache/apt/archives/lock /var/lib/dpkg/lock* 2> /dev/null
	sudo dpkg --configure -a
	sudo apt update
	#sudo apt upgrade -y
echo -e " --- [OK]\n"

# networking/wifi
echo -e "\n --- [TASK] Configuring networking and wifi..."
	network="ATT3tf4ur4"
	netpass="H3nrB1wan9n3t"
	configfile="50-cloud-init.yaml"
	sudo apt install net-tools wireless-tools wpasupplicant -y
	cp "/etc/netplan/$configfile" netplanconfig
	echo -e "    wifis:" >> netplanconfig
	echo -e "        wlan0:" >> netplanconfig
	echo -e "            optional: true" >> netplanconfig
	echo -e "            access-points:" >> netplanconfig
	echo -e "                \"ATT3tf4ur4:\"" >> netplanconfig
	echo -e "                    password: \"H3nrB1wan9n3t\"" >> netplanconfig
	echo -e "            dhcp4: true" >> netplanconfig
	
	
	
echo -e " --- [OK]\n"





### CLEANUP
echo -e "\n --- [TASK] Cleaning up..."
# remove unnecessary packages.
	sudo apt remove raspi-config -y &> /dev/null
	sudo apt autoremove -y
echo -e " --- [OK]\n"



### END.
echo -e " ----- [END] Raspberry Pi setup complete."
#!/bin/bash

# Install prereqs
echo -e "\n --- [TASK] Installing dependencies..."
    sudo apt install -y libts0 bc fbi git evtest libts-bin device-tree-compiler
    sudo apt install -y python3-dev python3-pip python3-smbus
    sudo pip3 install spidev evtest

    rotateparams="rotate=90,touch-swapxy=true,touch-invx=true"
    overlay=$(printf "dtoverlay=pitft28-capacitive,speed=64000000,fps=30\ndtoverlay=pitft28-capacitive,${rotateparams}")
    cat >> /boot/config.txt <<EOF
    dtparam=spi=on
    dtparam=i2c1=on
    dtparam=i2c_arm=on
    $overlay
EOF
    cat >> /boot/cmdline.txt <<EOF
    'rootwait fbcon=map:10 fbcon=font:VGA8x8' 
EOF
    cat >> /etc/default/console-setup <<EOF
    ACTIVE_CONSOLES="/dev/tty[1-6]"
    CHARMAP="UTF-8"
    CODESET="Uni2"
    FONTFACE="Terminus"
    FONTSIZE="6x12"
    VIDEOMODE=
EOF
    
    
    
    
    
    
    
    
    
    
echo -e "\n --- [OK]"
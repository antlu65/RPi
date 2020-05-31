#!/bin/bash
### Assistance script for configuring keyboard.

### General Script Variables & Functions
scriptName="Install Netcore 3"
scriptMaxArgs=0
scriptMinArgs=0
scriptRequireRootUser=1
beginScript() {
  echo ""
  echo " [BEGIN] $scriptName"
  echo "Executing $0 ..."
  uid=$(id -u)
  # Ensure root user if needed.  
  if [ "$scriptRequireRootUser" -eq 1 ] && [ "$uid" -ne 0 ]; then
    echo " --- [Error] Must be root user."
    exitScript -1
  # Ensure scriptDescription is not empty.
  elif [ -z "$scriptName" ]; then
    echo " --- [InternalError] scriptDescription is empty."
    exitScript -1
  # Ensure scriptMinArgs > 0.
  elif [ "$scriptMinArgs" -lt 0 ]; then
    echo " --- [InternalError] scriptMinArgs < 0."
    exitScript -1
  # Ensure scriptMaxArgs >= scriptMinArgs.
  elif [ "$scriptMaxArgs" -lt "$scriptMinArgs" ]; then
    echo " --- [InternalError] scriptMaxArgs < scriptMinArgs."
    exitScript -1
  # Ensure number of args >= scriptMinArgs.
  elif [ "$#" -lt "$scriptMinArgs" ]; then
    echo " --- [Error] Too few parameters ($#). Expected >= $scriptMinArgs."
    exitScript -1
  # Ensure args count <= scriptMaxArgs.
  elif [ "$#" -gt "$scriptMaxArgs" ]; then
    echo " --- [Error] Too many parameters ($#). Expected <= $scriptMaxArgs."
    exitScript -1
  fi
}
exitScript() { # $1 -> int for this script's exit code. 0 is success.
  echo "Exited with code $1."
  if [ "$1" -eq 0 ]; then
    echo "   [SUCCESS] $scriptName"
  else
    echo "   [FAILED] $scriptName"
  fi
  echo ""
  exit $1
}

### Script-specific Variables and Functions
installDir="/opt/dotnet"
archiveFile="dotnet_3.tar.gz"
downloadURL="https://download.visualstudio.microsoft.com/download/pr/f9c95fa6-0fa0-4fa5-b6f2-e782b4044b76/42cd3637fb99a9ffde1469ef936be0c3/dotnet-runtime-3.1.4-linux-arm.tar.gz"
linkDir="/usr/local/bin"
linkName="dotnet"


######## MAIN #######
beginScript

sudo apt install libunwind8 gettext -y -q
  
    # download
curl -o "$archiveFile" "$downloadURL"
checksumFile="${archiveFile}.sha512"
sha512sum "$archiveFile" > "$checksumFile"	
if [ $(sha512sum -c "$checksumFile") -ne 0 ]; then
    echo " --- [x] Checksum for downloaded archive '$archiveFile' does not match."
    rm "$archiveFile" "$checksumFile"
    exitScript -1
fi
sudo mkdir -p "$installDir"
sudo tar zxf "$archiveFile" -C "$installDir"
rm "$archiveFile" "$checksumFile"

if [ -h "$linkDir/$linkName" ]; then
    echo " --- [i] Link '$linkDir/$linkName' already exists."
else
    sudo ln -s /opt/dotnet/dotnet /usr/local/bin
fi

	



exitScript 0
######## EXIT #######
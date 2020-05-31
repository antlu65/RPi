#!/bin/bash
### Assistance script for configuring keyboard.

### General Script Variables & Functions
scriptName="Install Netcore 3"
scriptMaxArgs=1
scriptMinArgs=1
scriptRequireRootUser=1
beginScript() { # $1 -> int for number of extra parameters given to script.
  extraParamCount=$($1 - 1)
  echo ""
  echo "   [BEGIN] $scriptName"
  echo "Executing $0 ..."
  uid=$(id -u)
  # Ensure root user if needed.  
  if [ ${scriptRequireRootUser} -eq 1 ] && [ ${uid} -ne 0 ]; then
    echo " --- [x] Must be root user."
    exitScript 1
  # Ensure scriptDescription is not empty.
  elif [ -z "$scriptName" ]; then
    echo " --- [x] scriptDescription is empty."
    exitScript 1
  # Ensure scriptMinArgs > 0.
  elif [ ${scriptMinArgs} -lt 0 ]; then
    echo " --- [x] scriptMinArgs < 0."
    exitScript 1
  # Ensure scriptMaxArgs >= scriptMinArgs.
  elif [ ${scriptMaxArgs} -lt ${scriptMinArgs} ]; then
    echo " --- [x] scriptMaxArgs < scriptMinArgs."
    exitScript 1
  # Ensure number of args >= scriptMinArgs.
  elif [ ${extraParamCount} -lt ${scriptMinArgs} ]; then
    echo " --- [x] Too few extra parameters ($extraParamCount). Expected at least $scriptMinArgs."
    exitScript 1
  # Ensure args count <= scriptMaxArgs.
  elif [ ${extraParamCount} -gt ${scriptMaxArgs} ]; then
    echo " --- [x] Too many extra parameters ($extraParamCount). Expected at most $scriptMaxArgs."
    exitScript 1
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
downloadURL=""""
linkDir="/usr/local/bin"
linkName="dotnet"

### Script-specific Params
#$1 -> --arm32 or --arm64

######## MAIN #######
    beginScript $#

if [ "$1" == "--arm32" ]; then
    downloadURL="https://download.visualstudio.microsoft.com/download/pr/f9c95fa6-0fa0-4fa5-b6f2-e782b4044b76/42cd3637fb99a9ffde1469ef936be0c3/dotnet-runtime-3.1.4-linux-arm.tar.gz"
elif [ "$1" == "--arm64" ]; then
    downloadURL="https://download.visualstudio.microsoft.com/download/pr/da94a32f-8fa7-4df8-b54c-f3442dc2a17a/0badd31a0487b0318a3234baf023aa3c/dotnet-runtime-3.1.4-linux-arm64.tar.gz"
else
    echo " --- [x] Script param must be either '--arm32' or '--arm64'."
    exitScript 1
fi

sudo apt install libunwind8 gettext -y -q
curl -o "$archiveFile" "$downloadURL"
checksumFile="${archiveFile}.sha512"
sha512sum "$archiveFile" > "$checksumFile"
check=$(sha512sum -c ${checksumFile})
if [ "$check" != "$archiveFile: OK" ]; then
    echo " --- [x] Checksum for downloaded archive '$archiveFile' does not match."
    rm "$archiveFile" "$checksumFile"
    exitScript 1
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
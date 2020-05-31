#!/bin/bash
### Assistance script for configuring keyboard.

### General Script Variables & Functions
scriptName="Config Keyboard"
scriptMaxArgs=0
scriptMinArgs=0
scriptRequireRootUser=1
beginScript() { # $1 -> int for number of extra parameters given to script.
  extraParamCount=$($1 - 1)
  echo ""
  echo "   [BEGIN] $scriptName"
  echo "Executing $0 ..."
  uid=$(id -u)
  # Ensure root user if needed.  
  if [ "$scriptRequireRootUser" -eq 1 ] && [ "$uid" -ne 0 ]; then
    echo " --- [x] Must be root user."
    exitScript 1
  # Ensure scriptDescription is not empty.
  elif [ -z "$scriptName" ]; then
    echo " --- [x] scriptDescription is empty."
    exitScript 1
  # Ensure scriptMinArgs > 0.
  elif [ "$scriptMinArgs" -lt 0 ]; then
    echo " --- [x] scriptMinArgs < 0."
    exitScript 1
  # Ensure scriptMaxArgs >= scriptMinArgs.
  elif [ "$scriptMaxArgs" -lt "$scriptMinArgs" ]; then
    echo " --- [x] scriptMaxArgs < scriptMinArgs."
    exitScript 1
  # Ensure number of args >= scriptMinArgs.
  elif [ "$extraParamCount" -lt "$scriptMinArgs" ]; then
    echo " --- [x] Too few extra parameters ($#). Expected at least $scriptMinArgs."
    exitScript 1
  # Ensure args count <= scriptMaxArgs.
  elif [ "$extraParamCount" -gt "$scriptMaxArgs" ]; then
    echo " --- [x] Too many extra parameters ($#). Expected at most $scriptMaxArgs."
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
installDir="/etc/default"
fileName="keyboard"

######## MAIN #######
    beginScript $#
touch fileName
cat <<- EOF > ${fileName}
	XKBMODEL="pc105"
	XKBLAYOUT="us"
	XKBVARIANT=""
	XKBOPTIONS=""
	BACKSPACE="guess"
EOF
sudo mv -f "$fileName" "$installDir/$fileName"
echo "Created config file '$installDir/$fileName'."
    exitScript 0
######## EXIT #######
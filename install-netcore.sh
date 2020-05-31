#!/bin/bash
### Assistance script for downloading and installing most recent .NET Core runtimes.

### General Script Variables & Functions
scriptDescription="Install .NET Core Runtimes"
scriptMaxArgs=1
scriptMinArgs=1
scriptRequireRootUser=1
beginScript() {
  echo -e "\n Executing $0 ..."
  echo -e "------- [BEGIN] $scriptDescription ..."
  
  # Ensure root user if needed.  
  if [[ "$scriptRequireRootUser" -eq 1 ]] && [[ "$EUID" -ne 0 ]]; then
    echo " --- [Error] Must be root user."
    exitScript -1
  # Ensure scriptDescription is not empty.
  elif [[ -n "$scriptDescription" ]]; then
    echo " --- [InternalError] scriptDescription is empty."
    exitScript -1
  # Ensure scriptMinArgs > 0.
  elif [[ "$scriptMinArgs" -lt 0 ]]; then
    echo " --- [InternalError] scriptMinArgs < 0."
    exitScript -1
  # Ensure scriptMaxArgs >= scriptMinArgs.
  elif [[ "$scriptMaxArgs" -lt "$scriptMinArgs" ]]; then
    echo " --- [InternalError] scriptMaxArgs < scriptMinArgs."
    exitScript -1
  # Ensure number of args >= scriptMinArgs.
  elif [[ "$#" -lt "$scriptMinArgs" ]]; then
    echo " --- [Error] Too few parameters ($#). Expected >= $scriptMinArgs."
    exitScript -1
  # Ensure args count <= scriptMaxArgs.
  elif [[ "$#" -gt "$scriptMaxArgs" ]]; then
    echo " --- [Error] Too many parameters ($#). Expected <= $scriptMaxArgs."
    exitScript -1
  fi
}
exitScript() { # $1 -> int for this script's exit code. 0 is success.
  if [[ "$1" -eq 0 ]]; then
    echo -e " ------- [SUCCESS] $scriptDescription."
  else
    echo -e " ------- [FAILED] $scriptDescription."
  fi
  echo -e "\n Exited $0 ..."
  exit "$1"
}


### Script-specific Variables and Functions
defaultInstallDir="/opt/dotnet"



### SCRIPT BEGIN
  # Ensure dotnet not already installed.

    if [[ -x "$defaultInstallDir/dotnet" ]]; then
      echo " --- [Info] Dotnet executable already installed."
      exit
    fi

#!/usr/bin/env bash

set +ex

# Check for the user operating system
# Identify what to use to install wget, node, curl
# Install the packages and verify they install correctly

install_brew() {
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

install_packages_brew() {
  brew install wget curl node
}

install_packages_choco() {
  choco install -y wget curl node
  
}

check_brew() {
  OS=$1
  if [ -z $(which brew) ] 
  then
    echo "Brew not found, installing brew for ${OS}"
    case ${OS} in 
    Darwin) install_brew;;
    Linux) install_brew;;
    *) echo "Brew not supported for OS ${OS}"; exit;;
    esac
  else
    echo "Brew is installed already, proceeding to install packages"
  fi
}

install_choco() {
   $(which powershell) -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"
   $(which powershell) -NoProfile -InputFormat None  -ExecutionPolicy Bypass -Command "[System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";" + $Env:ALLUSERSPROFILE "\chocolatey\bin", "user")
"
}

test_choco() {
  if [ -z $(which choco) ]
  then
    exit "Error occurred installing chocolatey"
  else 
    echo "Chocolatey installed successfully"
  fi
}

check_choco() {
  if [ -z $(which choco) ] 
  then
    install_choco
    test_choco
  else
    echo "chocolatey is already installed"
  fi
}

check_os_and_install_packages() {
  if [ "$(uname)" == "Darwin" ]; then
      # Do something under Mac OS X platform   
      check_brew "Darwin" 
      install_packages_brew
  elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
      # Do something under GNU/Linux platform
      DISTRO=$(cat /etc/os-release | grep ID_LIKE | sed -e 's/ID_LIKE=//')
      echo "Linux on ${DISTRO}"   
      check_brew "Linux"
      install_packages_brew
  elif [ "$(expr substr $(uname -s) 1 5)" == "MINGW" ]; then
      # Do something under 32 bits Windows NT platform
      echo "Windows"
      check_choco
      install_packages_choco
  else
      echo "Unsupported OS, kindly install manually!"
  fi
}

check_os
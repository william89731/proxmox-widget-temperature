#!/bin/bash

NODES_DIR=${NODES_DIR:-/usr/share/perl5/PVE/API2}

#PROXMOXLIB_DIR=${PROXMOXLIB_DIR:-/usr/share/javascript/proxmox-widget-toolkit}

#PVEMANAGERLIB_DIR=${PVEMANAGERLIB_DIR:-/usr/share/pve-manager/js}

INFO()  {
  echo -e "\e[32m $*\e[39m";
  }

WARN()  {
  echo -e "\e[33m $*\e[39m";
  }

ERROR() {
  echo -e "\e[31m $*\e[39m";
  exit 1
  }

PAUSE() {
  echo "pause..." & sleep 3000
}


HEADER_INFO() {
  clear
  echo "
  ██████╗ ██╗   ██╗███████╗    ██╗    ██╗██╗██████╗  ██████╗ ███████╗████████╗
  ██╔══██╗██║   ██║██╔════╝    ██║    ██║██║██╔══██╗██╔════╝ ██╔════╝╚══██╔══╝
  ██████╔╝██║   ██║█████╗      ██║ █╗ ██║██║██║  ██║██║  ███╗█████╗     ██║
  ██╔═══╝ ╚██╗ ██╔╝██╔══╝      ██║███╗██║██║██║  ██║██║   ██║██╔══╝     ██║
  ██║      ╚████╔╝ ███████╗    ╚███╔███╔╝██║██████╔╝╚██████╔╝███████╗   ██║
  ╚═╝       ╚═══╝  ╚══════╝     ╚══╝╚══╝ ╚═╝╚═════╝  ╚═════╝ ╚══════╝   ╚═╝
"
sleep 2
clear
}

PATCH() {
  #check if patch is already applied
  # command find $PROXMOXLIB_DIR/proxmoxlib.js.ori > /dev/null 2>&1 || FILE="not found"
  # command find $PVEMANAGERLIB_DIR/pvemanagerlib.js.ori > /dev/null 2>&1 || FILE="not found"
  command find $NODES_DIR/Nodes.pm.orig  > /dev/null 2>&1 || FILE+=("not found")
  if [[ "$FILE" != "not found" ]]; then
    ERROR "patch already applied"
  else
    INFO "apply patch.."
    #check necessay package
    command -v patch > /dev/null 2>&1 || MISSING_PACKAGES+=("patch")
    if [[ "$MISSING_PACKAGES" == "patch" ]]; then
      sudo apt update
      sudo apt install -y $MISSING_PACKAGES
    fi

    command -v sensors > /dev/null 2>&1 || MISSING_PACKAGES+=("sensors")
    if [[ "$MISSING_PACKAGES" == "sensors" ]]; then
      ERROR "please, install lm-sensor"
    fi
    # download and apply patch
    command curl -sSfLo Nodes.pm.patch https://raw.githubusercontent.com/william89731/proxmox-widget-temperature/refs/heads/main/Nodes.pm.patch
    if [ $? -ne 0 ]; then
      ERROR "problem downlaod patch"
    else
      command patch -b /usr/share/perl5/PVE/API2/Nodes.pm Nodes.pm.patch
    fi

    command curl -sSfLo proxmoxlib.js.patch https://raw.githubusercontent.com/william89731/proxmox-widget-temperature/refs/heads/main/proxmoxlib.js.patch
    if [ $? -ne 0 ]; then
      ERROR "problem downlaod patch"
    else
      command patch -b /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js proxmoxlib.js.patch
    fi

    command curl -sSfLo pvemanagerlib.js.patch https://raw.githubusercontent.com/william89731/proxmox-widget-temperature/refs/heads/main/pvemanagerlib.js.patch
    if [ $? -ne 0 ]; then
      ERROR "problem downlaod patch"
    else
      command patch -b /usr/share/pve-manager/js/pvemanagerlib.js pvemanagerlib.js.patch
    fi

    rm *.patch


  fi
}

REMOVE() {
  command find $NODES_DIR/Nodes.pm.orig  > /dev/null 2>&1 || FILE+=("not found")
  if [[ "$FILE" != "not found" ]]; then
    command rm /usr/share/perl5/PVE/API2/Nodes.pm
    command mv /usr/share/perl5/PVE/API2/Nodes.pm.orig /usr/share/perl5/PVE/API2/Nodes.pm

    command rm /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
    command mv /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js.orig /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js

    command rm /usr/share/pve-manager/js/pvemanagerlib.js
    command mv /usr/share/pve-manager/js/pvemanagerlib.js.orig /usr/share/pve-manager/js/pvemanagerlib.js
  else
    ERROR "patch not applied"
  fi
}

SENSOR_CONFIG() {
  HDDSENSOR=$(sensors | grep "drive" )
  if [[ ! -z "$HDDSENSOR" ]]; then
  #echo "$HDDSENSOR"
  sed -i 's/sensor-name-adapter/'$HDDSENSOR'/g' /usr/share/perl5/PVE/API2/Nodes.pm
  sed -i 's/val-input/temp1/g' /usr/share/perl5/PVE/API2/Nodes.pm
  fi

  NVMESENSOR=$(sensors | grep "nvme" )
  if [[ ! -z "$NVMESENSOR" ]]; then
  #echo "$NVESENSOR"
  sed -i 's/sensor-name-adapter/'$NVMESENSOR'/g' /usr/share/perl5/PVE/API2/Nodes.pm
  sed -i 's/val-input/Composite/g' /usr/share/perl5/PVE/API2/Nodes.pm
  fi
}

START_ROUTINE() {
  WARN "Tested on pve-manager 8.2.7. Take your own risks!"

  sleep 4 & echo ""

  INFO "do you Apply[A] or Remove[R] patch?";
  read;

  if [[ $REPLY =~ ^(A) ]]; then
    clear
    PATCH
    SENSOR_CONFIG
  elif [[ $REPLY =~ ^(R) ]]; then
    clear
    WARN "remove patch"
    REMOVE
  else
    ERROR "exit"
  fi
}

HEADER_INFO

START_ROUTINE

command systemctl restart pveproxy

clear

INFO "clear cache browser"

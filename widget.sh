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
sleep 3
clear
}

PATCH() {
  command find $NODES_DIR/Nodes.pm.ori  > /dev/null 2>&1 || FILE+=("not found")
  # command find $PROXMOXLIB_DIR/proxmoxlib.js.ori > /dev/null 2>&1 || FILE="not found"
  # command find $PVEMANAGERLIB_DIR/pvemanagerlib.js.ori > /dev/null 2>&1 || FILE="not found"
  if [[ "$FILE" != "not found" ]]; then
    ERROR "patch already applyed"
  else
    INFO "apply patch.."

    command -v patch > /dev/null 2>&1 || MISSING_PACKAGES+=("patch")
    if [[ "$MISSING_PACKAGES" == "patch" ]]; then
      sudo apt update
      sudo apt install -y $MISSING_PACKAGES
    fi

    command -v sensors > /dev/null 2>&1 || MISSING_PACKAGES+=("sensors")
    if [[ "$MISSING_PACKAGES" == "sensors" ]]; then
      ERROR "please, install lm-sensor"
    fi
    # download patch
    command curl -sSfLo Nodes.pm.patch https://raw.githubusercontent.com/Nodes.pm.patch
    if [ $? -ne 0 ]; then
      ERROR "problem downlaod patch"
    fi

    command curl -sSfLo proxmoxlib.js.patch https://raw.githubusercontent.com//Nodes.pm.patch
    if [ $? -ne 0 ]; then
      ERROR "problem downlaod patch"
    fi

    command curl -sSfLo pvemanagerlib.js.patch https://raw.githubusercontent.com//Nodes.pm.patch
    if [ $? -ne 0 ]; then
      ERROR "problem downlaod patch"
    fi
    #apply patch
    command patch -b /usr/share/perl5/PVE/API2/Nodes.pm Nodes.pm.patch
    command patch -b /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js proxmoxlib.js.patch
    command patch -b /usr/share/pve-manager/js/pvemanagerlib.js pvemanagerlib.js.patch

    rm *.patch

    command systemctl restart pve.proxy
  fi

}

START_ROUTINE() {
  INFO "do you Apply[A] or Remove[R] patch?";
  read;

  if [[ $REPLY =~ ^(A) ]]; then
    clear
    PATCH
  elif [[ $REPLY =~ ^(R) ]]; then
    clear
    WARN "remove patch"
    #RESTORE
  else
    ERROR "finish program"
  fi
}

#HEADER_INFO

START_ROUTINE

clear

INFO "clear cache browser"


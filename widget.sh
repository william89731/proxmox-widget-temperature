#!/bin/bash

NODES_DIR=${NODES_DIR:-/usr/share/perl5/PVE/API2}

# set -o errexit
#
# set -o pipefail
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
  ██████╗ ██████╗  ██████╗ ██╗  ██╗███╗   ███╗ ██████╗ ██╗  ██╗
  ██╔══██╗██╔══██╗██╔═══██╗╚██╗██╔╝████╗ ████║██╔═══██╗╚██╗██╔╝
  ██████╔╝██████╔╝██║   ██║ ╚███╔╝ ██╔████╔██║██║   ██║ ╚███╔╝
  ██╔═══╝ ██╔══██╗██║   ██║ ██╔██╗ ██║╚██╔╝██║██║   ██║ ██╔██╗
  ██║     ██║  ██║╚██████╔╝██╔╝ ██╗██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗
  ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝
  "
  sleep 3
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
    echo ""
    sleep 3
    #check necessay package
    command -v patch > /dev/null 2>&1 || MISSING_PACKAGES+=("patch")
    if [[ "$MISSING_PACKAGES" == "patch" ]]; then
      command apt update
      command apt install -y $MISSING_PACKAGES
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
  INFO "remove patch.."
  echo ""
  sleep 3
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

RESTORE() {
  INFO "restore original files.."
  echo ""
  sleep 3
  command rm /usr/share/perl5/PVE/API2/Nodes.pm.orig
  command rm /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js.orig
  command rm /usr/share/pve-manager/js/pvemanagerlib.js.orig
  command apt install --reinstall pve-manager proxmox-widget-toolkit
}

START_ROUTINE() {
  OPTS=$(whiptail \
    --title "Proxmox Widget Temperature" \
    --menu "Tested on pve-manager 8.2.7. Take your own risks!" 14 58 3 \
    "Apply patch" " " \
    "Remove patch" " " \
    "Restore original files" " " 3>&2 2>&1 1>&3)

  if [[ $OPTS == 'Apply patch' ]]; then
  PATCH
  SENSOR_CONFIG

  elif [[ $OPTS == "Remove patch" ]]; then
  REMOVE

  elif [[ $OPTS == "Restore original files" ]]; then
  RESTORE

  else
  ERROR "exit"

  fi
}

HEADER_INFO

START_ROUTINE

command systemctl restart pveproxy

clear

INFO "clear cache browser"

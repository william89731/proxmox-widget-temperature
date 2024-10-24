#!/bin/bash

NODES_DIR=${NODES_DIR:-/usr/share/perl5/PVE/API2}

# set -o errexit
#
# set -o pipefail
#PROXMOXLIB_DIR=${PROXMOXLIB_DIR:-/usr/share/javascript/proxmox-widget-toolkit}

#PVEMANAGERLIB_DIR=${PVEMANAGERLIB_DIR:-/usr/share/pve-manager/js}

INFO() {
  echo -e "\e[32m $*\e[39m"
}

WARN() {
  echo -e "\e[33m $*\e[39m"
}

ERROR() {
  echo -e "\e[31m $*\e[39m"
  exit 1
}

PAUSE() {
  echo "pause..." &
  sleep 3000
}

LOGO() {
  clear
  cat <<"EOF"

  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠦⢤⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠙⠳⢦⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⠞⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⢦⡄⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢷⡀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣦⡀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⡄⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡼⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣉⣉⣙⠣⠄⠀⠀⠀⠉⠉⠉⠛⠶⢦⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⡄
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⢀⣡⡴⠾⣿⡉⠛⢿⣦⠀⢀⣰⠶⠛⠛⠻⢶⣄⡙⢢⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣤⡶⣶⣤⣀⠸⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢷⣿⢃⢴⣿⣿⣿⣶⡀⠹⣶⠟⣡⣾⣿⣿⣶⡄⠙⢷⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡼⠋⢁⡴⢧⡀⢉⣛⣿⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⡏⠈⣿⣿⣿⣿⣿⣷⠀⠟⠀⣿⣿⣿⣿⣿⣿⠀⢸⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⢀⣴⡟⠁⣰⡿⠁⠀⣹⠟⢋⣡⣿⢧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠟⣷⡀⠸⣿⣿⣿⡿⠃⠀⣦⠀⠛⣿⣿⣿⣿⡏⠀⣼⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⢀⣴⡾⠛⠉⡿⠸⡏⠀⢀⡾⠉⢉⣾⠯⣥⡈⠻⣧⠀⠀⠀⠀⠀⠀⠀⠸⣬⣿⡆⠀⠀⠁⠀⢀⣀⠘⢷⣤⡈⠉⠙⠃⣨⣾⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⣰⡏⠉⢇⡞⠶⢷⡀⠹⣄⠘⠀⣰⡟⠀⢀⡞⠉⠁⠺⣷⡀⠀⠀⠀⠀⠀⠀⠀⠙⢿⡷⣤⣴⣶⠞⠁⠀⠀⠙⠿⢾⣷⡿⠿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⣿⠠⠀⠈⠓⠀⠠⢷⣄⠘⢷⣀⠹⡄⢠⡼⠀⠀⠀⢀⣿⢻⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⢀⣿⠀⠀⠀⠀⠀⠀⠰⡦⠀⠀⠻⣆⡑⠏⠀⠀⠀⠀⣼⣿⡍⠛⢿⣦⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⢠⣾⢻⣦⠀⠀⠀⠀⠀⠀⠈⠀⠀⠀⠚⠻⣦⣤⣤⣴⣿⣋⣹⣷⠀⢠⡈⢻⣿⣷⣦⣄⣤⣤⣄⣀⣤⣤⣤⣤⣤⣤⣤⣠⣤⣤⣤⣤⣤⣤⣤⣤⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⢠⡟⠀⠘⢿⣆⡈⢷⣄⠀⠀⠀⠙⡄⠀⠛⠂⣀⠘⠠⠟⣿⣿⠁⣿⣀⣼⠟⠉⣀⠀⠸⣿⡟⣿⡿⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⣿⡿⠟⠃⠀⠀⠀⠀⠀⠀⠀⠀
  ⢸⠁⠀⠀⠀⠻⠧⣄⣿⣷⡀⠀⠀⠀⠀⠀⠀⠈⠱⠀⠈⠙⣿⣿⣿⣿⡿⠷⠂⠹⢧⠀⣾⣿⠉⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡄⠀
  ⢸⠀⠀⠀⠀⠀⠀⠹⠿⣿⣻⣦⡀⠀⠀⠀⠀⠀⢀⡀⠀⠑⠾⣿⣿⡿⠸⠆⠠⠆⠀⠀⢸⢻⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⢣⡾⠃⠀
  ⡞⠀⢀⠀⠀⠀⠀⠀⠀⠐⠀⢙⣿⣦⡀⠀⠀⣴⠟⡁⠀⠀⣰⣿⡟⠓⢰⣆⡼⠦⢄⠀⠬⡷⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠴⢞⡵⠛⠀⠀⠀
  ⠇⠀⠘⠻⣦⣄⠄⠀⢠⡀⠀⠀⠛⠛⣷⣄⡀⠉⠀⠽⢀⣾⣿⠟⢀⣴⢾⡟⢧⡀⡀⠙⣆⣶⠟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠜⢃⡴⠋⠀⠀⠀⠀⠀
  ⣄⠀⠀⠀⠉⠛⢷⣄⠀⠙⣄⠀⠀⠀⠙⣏⡛⢷⣄⣘⢻⣿⡏⠀⢾⠁⠸⣷⣈⣿⣤⠾⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣎⣵⠾⠋⠀⠀⠀⠀⠀⠀⠀
  ⠸⣦⡄⠀⠀⠀⠀⡙⢷⣄⠈⠀⠀⠀⣀⡞⠁⡇⠈⣹⡿⠋⢷⠀⢸⡆⢠⣾⡿⠋⠙⠷⢦⣄⣀⣀⡀⠀⠀⠀⠀⠀⣀⣀⠀⠀⣀⣠⣿⠷⠞⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠈⠳⣄⡀⠀⠀⠀⠀⠈⠻⣦⣀⠀⠈⠀⠇⣃⡼⠟⠁⠀⠀⠳⢤⣷⡿⠟⠀⠀⠀⠀⠀⠀⠈⠙⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠙⠲⣤⡀⠀⠀⠀⣠⠙⠓⢶⣤⡾⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠉⠓⠶⣤⣀⣘⣴⠞⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀github.com/william89731⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀

EOF
  sleep 3
  clear
}

UPDATE() {
  clear
  command find "$NODES_DIR"/Nodes.pm.orig >/dev/null 2>&1 || FILE+=("false")

  if [[ "${FILE[*]}" == "false" ]]; then
    ERROR "patch not found"

  else
    clear
    INFO "update patch.."
    sleep 3
    # download and update patch
    command curl -sSfLo Nodes.pm.patch https://raw.githubusercontent.com/william89731/proxmox-widget-temperature/refs/heads/main/Nodes.pm.patch >/dev/null 2>&1 || PATCH+=("false")
    if [ "${PATCH[*]}" == "false" ]; then
      ERROR "problem downlaod patch"
    else
      command rm /usr/share/perl5/PVE/API2/Nodes.pm >/dev/null 2>&1
      command mv /usr/share/perl5/PVE/API2/Nodes.pm.orig /usr/share/perl5/PVE/API2/Nodes.pm >/dev/null 2>&1
      command patch -b /usr/share/perl5/PVE/API2/Nodes.pm Nodes.pm.patch >/dev/null 2>&1
    fi

    command curl -sSfLo proxmoxlib.js.patch https://raw.githubusercontent.com/william89731/proxmox-widget-temperature/refs/heads/main/proxmoxlib.js.patch >/dev/null 2>&1 || PATCH+=("false")
    if [ "${PATCH[*]}" == "false" ]; then
      ERROR "problem downlaod patch"
    else
      command rm /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js >/dev/null 2>&1
      command mv /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js.orig /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js >/dev/null 2>&1
      command patch -b /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js proxmoxlib.js.patch >/dev/null 2>&1
    fi

    command curl -sSfLo pvemanagerlib.js.patch https://raw.githubusercontent.com/william89731/proxmox-widget-temperature/refs/heads/main/pvemanagerlib.js.patch >/dev/null 2>&1 || PATCH+=("false")
    if [ "${PATCH[*]}" == "false" ]; then
      ERROR "problem downlaod patch"
    else
      command rm /usr/share/pve-manager/js/pvemanagerlib.js >/dev/null 2>&1
      command mv /usr/share/pve-manager/js/pvemanagerlib.js.orig /usr/share/pve-manager/js/pvemanagerlib.js >/dev/null 2>&1
      command patch -b /usr/share/pve-manager/js/pvemanagerlib.js pvemanagerlib.js.patch >/dev/null 2>&1
    fi

    # shellcheck disable=SC2035
    rm *.patch
  fi

  RESULT="Patch updated \nclear cache browser"
}

PATCH() {
  #check if patch is already applied
  command find "$NODES_DIR"/Nodes.pm.orig >/dev/null 2>&1 || FILE+=("false")

  if [[ "${FILE[*]}" != "false" ]]; then
    ERROR "patch already applied"

  else
    clear
    INFO "apply patch.."
    echo ""
    sleep 3
    #check necessay package
    command -v patch >/dev/null 2>&1 || MISSING_PACKAGES+=("patch")
    if [[ "${MISSING_PACKAGES[*]}" == "patch" ]]; then
      command apt-get update >/dev/null 2>&1
      command apt-get install -y "${MISSING_PACKAGES[*]}" >/dev/null 2>&1
    fi

    command -v sensors >/dev/null 2>&1 || MISSING_PACKAGES+=("sensors")
    if [[ "${MISSING_PACKAGES[*]}" == "sensors" ]]; then
      ERROR "please, install lm-sensor"
    fi
    # download and apply patch
    command curl -sSfLo Nodes.pm.patch https://raw.githubusercontent.com/william89731/proxmox-widget-temperature/refs/heads/main/Nodes.pm.patch >/dev/null 2>&1 || PATCH+=("false")
    if [ "${PATCH[*]}" == "false" ]; then
      ERROR "problem downlaod patch"
    else
      command patch -b /usr/share/perl5/PVE/API2/Nodes.pm Nodes.pm.patch >/dev/null 2>&1
    fi

    command curl -sSfLo proxmoxlib.js.patch https://raw.githubusercontent.com/william89731/proxmox-widget-temperature/refs/heads/main/proxmoxlib.js.patch >/dev/null 2>&1 || PATCH+=("false")
    if [ "${PATCH[*]}" == "false" ]; then
      ERROR "problem downlaod patch"
    else
      command patch -b /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js proxmoxlib.js.patch >/dev/null 2>&1
    fi

    command curl -sSfLo pvemanagerlib.js.patch https://raw.githubusercontent.com/william89731/proxmox-widget-temperature/refs/heads/main/pvemanagerlib.js.patch >/dev/null 2>&1 || PATCH+=("false")
    if [ "${PATCH[*]}" == "false" ]; then
      ERROR "problem downlaod patch"
    else
      command patch -b /usr/share/pve-manager/js/pvemanagerlib.js pvemanagerlib.js.patch >/dev/null 2>&1
    fi

    # shellcheck disable=SC2035
    rm *.patch
  fi

  RESULT="patch applied \nclear cache browser"
}

REMOVE() {
  clear
  INFO "remove patch.."
  echo ""
  sleep 3
  command find "$NODES_DIR"/Nodes.pm.orig >/dev/null 2>&1 || FILE+=("false")
  if [[ "${FILE[*]}" != "false" ]]; then
    command rm /usr/share/perl5/PVE/API2/Nodes.pm >/dev/null 2>&1
    command mv /usr/share/perl5/PVE/API2/Nodes.pm.orig /usr/share/perl5/PVE/API2/Nodes.pm >/dev/null 2>&1
    command rm /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js >/dev/null 2>&1
    command mv /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js.orig /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js >/dev/null 2>&1
    command rm /usr/share/pve-manager/js/pvemanagerlib.js >/dev/null 2>&1
    command mv /usr/share/pve-manager/js/pvemanagerlib.js.orig /usr/share/pve-manager/js/pvemanagerlib.js >/dev/null 2>&1

  else
    ERROR "patch not applied"
  fi

  RESULT="patch removed \nclear cache browser"

}

SENSOR_CONFIG() {
  HDDSENSOR=$(command sensors | grep "drive") >/dev/null 2>&1 || HDDSENSOR+=("false")
  if [[ "${HDDSENSOR[*]}" != "false" ]]; then

    sed -i "s/sensor-name-adapter/${HDDSENSOR[*]}/g" /usr/share/perl5/PVE/API2/Nodes.pm
    sed -i "s/val-input/temp1/g" /usr/share/perl5/PVE/API2/Nodes.pm
  fi

  NVMESENSOR=$(command sensors | grep "nvme") >/dev/null 2>&1 || NVMESENSOR+=("false")
  if [[ "${NVMESENSOR[*]}" != "false" ]]; then
    #echo "$NVESENSOR"
    sed -i "s/sensor-name-adapter/${NVMESENSOR[*]}/g" /usr/share/perl5/PVE/API2/Nodes.pm
    sed -i "s/val-input/Composite/g" /usr/share/perl5/PVE/API2/Nodes.pm
  fi
}

RESTORE() {
  clear
  INFO "restore original files.."
  echo ""
  sleep 3
  command rm /usr/share/perl5/PVE/API2/Nodes.pm.orig >/dev/null 2>&1
  command rm /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js.orig >/dev/null 2>&1
  command rm /usr/share/pve-manager/js/pvemanagerlib.js.orig >/dev/null 2>&1
  command apt install --reinstall pve-manager proxmox-widget-toolkit >/dev/null 2>&1
  #command systemctl restart pveproxy
  RESULT="original files restored \nclear cache browser"
}

ROUTINE() {
  clear
  while true; do
    OPTS=$(whiptail \
      --title "Proxmox Widget Temperature" \
      --menu "Tested on pve-manager 8.2.7. Take your own risks!" 14 58 4 \
      "UPDATE" "update patch " \
      "APPLY" "apply patch " \
      "REMOVE" "remove patch " \
      "RESTORE" "restore original files " 3>&2 2>&1 1>&3)

    case "$OPTS" in
    UPDATE)
      UPDATE
      SENSOR_CONFIG
      ;;

    APPLY)
      PATCH
      SENSOR_CONFIG
      ;;

    REMOVE)
      REMOVE
      ;;

    RESTORE)
      RESTORE
      ;;

    *)
      ERROR "exit"
      ;;

    esac

    command systemctl restart pveproxy
    whiptail --msgbox "$RESULT" 10 40
  done
}

LOGO

ROUTINE

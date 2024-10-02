![pctemp](https://github.com/user-attachments/assets/1cbd2b84-271e-4ddd-b3f8-29809f50c7ae)

[![os](https://img.shields.io/badge/os-proxmox-black_red)](https://www.linux.org/)
[![script](https://img.shields.io/badge/script-bash-orange)](https://www.gnu.org/software/bash/)
[![license](https://img.shields.io/badge/license-Apache--2.0-yellowgreen)](https://apache.org/licenses/LICENSE-2.0)
[![donate](https://img.shields.io/badge/donate-wango-blue)](https://www.wango.org/donate.aspx)

# Proxmox widget temperature

### Disclaimer
- this mod must be erase after update packages
- take your own risks!
- if you have problem:
  ```bash
  apt install --reinstall libtemplate-perl
  ```
  ```bash
  systemctl restart pveproxy
  ```

### Install

![image](https://github.com/user-attachments/assets/4421b2c3-b5d3-493c-92bc-d5cda59b0cb7)


in your terminal, run:

```bash
bash -c "$(wget -qLO - https://raw.githubusercontent.com/william89731/proxmox-widget-temperature/refs/heads/main/widget.sh)"
```

and follow instruction

### troubleshooting

![image](https://github.com/user-attachments/assets/926af351-4365-45dc-8b9d-ae243bda0e29)


- After applied this patch, no data is read

  ```solution```:

  run command:

  ```bash
  sensor -j
  ```
  the output read data sensors in your machine.

![image](https://github.com/user-attachments/assets/e924bcf0-24bf-4929-9e01-576f49c0adc9)


  now, you can change file /usr/share/perl5/PVE/API2/Nodes.pm and adjust your values. later, run ```systemctl restart pveproxy``` and clear cache browser

### Credit

thanks to [alexleigh](https://github.com/alexleigh)

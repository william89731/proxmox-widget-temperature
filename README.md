![pctemp](https://github.com/user-attachments/assets/1cbd2b84-271e-4ddd-b3f8-29809f50c7ae)

[![os](https://img.shields.io/badge/os-proxmox-black_red)](https://www.linux.org/)
[![script](https://img.shields.io/badge/script-bash-orange)](https://www.gnu.org/software/bash/)
[![license](https://img.shields.io/badge/license-Apache--2.0-yellowgreen)](https://apache.org/licenses/LICENSE-2.0)
[![donate](https://img.shields.io/badge/donate-wango-blue)](https://www.wango.org/donate.aspx)

# Proxmox widget temperature

![image](https://github.com/user-attachments/assets/4421b2c3-b5d3-493c-92bc-d5cda59b0cb7)

### Disclaimer
- this mod must be erase after update packages
- take your own risks!


### Install

in your terminal, run:

```bash
bash -c "$(wget -qLO - https://raw.githubusercontent.com/william89731/proxmox-widget-temperature/refs/heads/main/widget.sh)"
```

![image](https://github.com/user-attachments/assets/d090918c-48e7-4a7c-bcc1-c3cc1af349ee)





and follow instruction

### troubleshooting

- After applied this patch, no data is read

![image](https://github.com/user-attachments/assets/926af351-4365-45dc-8b9d-ae243bda0e29)

  ```solution```:

  run command:

  ```bash
  sensor -j
  ```
  the output read data sensors in your machine.

  ![image](https://github.com/user-attachments/assets/99b29a4f-4540-46d4-80ee-8bb57ccaa6e4)


  now, you can change file /usr/share/perl5/PVE/API2/Nodes.pm and adjust your values. later, run ```systemctl restart pveproxy``` and clear cache browser

![image](https://github.com/user-attachments/assets/9b65774d-7b5b-4775-a963-3aa5ae177f09)

  


### Credit

thanks to [alexleigh](https://github.com/alexleigh)

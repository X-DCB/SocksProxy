# SocksProxy with Client Auto-Disconnect
## By Dexter Cellona Banawon

![image](https://user-images.githubusercontent.com/28706220/176683823-3a4ea9a5-beb4-4501-b5d9-9782acd37d02.png)

[![Stars](https://img.shields.io/github/stars/X-DCB/SocksProxy)]()
[![Forks](https://img.shields.io/github/forks/X-DCB/SocksProxy)]()

Installer : `bash -c "$(wget -qO- https://git.io/J0Igf)"`

Updater   : `bash -c "$(wget -qO- https://git.io/J0Izx)"`

Download OpenVPN Config using the format:
  - `http://<IP or domain>/<IP>.ovpn`

### Ports:
  - 22 (SSH)
  - 550 (Dropbear)
  - 1194 (OpenVPN)
  - 80 (WS + SSH/Dropbear)
  - 2082 (WS + OpenVPN)
  - 443 (TLS/SSL + WS + SSH/Dropbear)
  - 2083 (TLS/SSL + WS + OpenVPN)

### Downloads
  1. Put the files inside `/etc/socksproxy/web` directory.
  2. Download a file using the format:

 `http://<IP or Domain>/<file name + extension>`

### Server Response Message
  1. Edit/Create `/etc/socksproxy/message` file.
  2. Restart `socksproxy` via `systemctl` command.

### Note: Use `xdcb` command to operate.

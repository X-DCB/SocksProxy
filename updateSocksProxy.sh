#!/bin/bash
clear
export DEBIAN_FRONTEND=noninteractive
if [ "$(id -u)" -ne 0 ]; then
  echo -ne "\nPlease execute this script as root.\n"
  exit 1; fi
if [ ! -f /etc/debian* ]; then
  echo -ne "\nFor DEBIAN and UBUNTU only.\n"
  exit 1; fi

loc=/etc/socksproxy
cont=socksproxyX
image=xdcb/smart-bypass:$cont

if [ -d $loc ]; then
echo "Updating SocksProxy..."
if [ -f "$loc/basic.conf" ]; then
  mv $loc/basic.conf $loc/server.conf
else
cat << 'basic' > $loc/server.conf
[ssh]
timer = 0
sport = 80
dport = 22

[openvpn]
timer = 0
sport = 8880
dport = 1194
basic
fi
[ -f $loc/message ] || echo "<font color=\"green\">Dexter Cellona Banawon (X-DCB)</font>" > $loc/message
rm -f $loc/.firstrun
systemctl stop socksproxy
docker rm -f $cont
docker rmi -f $image
docker create --name $cont \
  -v $loc:/conf \
  --net host --cap-add NET_ADMIN $image
systemctl start socksproxy
echo "Update done!"
else echo "SocksProxy directory not found!";fi

exit 0
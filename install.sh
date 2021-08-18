#!/bin/bash
clear
export DEBIAN_FRONTEND=noninteractive
if [ "$(id -u)" -ne 0 ]; then
  echo -ne "\nPlease execute this script as root.\n"
  exit 1; fi
if [ ! -f /etc/debian* ]; then
  echo -ne "\nFor DEBIAN and UBUNTU only.\n"
  exit 1; fi

cat << info

 ==================================
|    Socks Proxy for SocksHttp     |
|    by Dexter Cellona Banawon     |
 ==================================
   - Client Auto-Disconnect
   - Multiport
   - Stabilized timer
   - Config based (server.conf)
   - Menu for accounts management
   - Server optimization
   - Beta Version
   - UDP Forwading
   - Static website support

info

read -p "Press ENTER to continue..."

clear
. /etc/os-release
MYIP=$(wget -qO- ipv4.icanhazip.com)

echo "Configuring SSH."
cd /etc/ssh
needpass=`grep '^TrustedUserCAKeys' sshd_config`
[ -f "sshd_config-old" ] || mv sshd_config sshd_config-old
cat << ssh > sshd_config
Port 22
PermitRootLogin yes
PubkeyAuthentication no
PasswordAuthentication yes
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding yes
PrintMotd no
AcceptEnv LANG LC_*
Subsystem sftp  /usr/lib/openssh/sftp-server
ClientAliveInterval 120
ssh
cd /etc/pam.d
[ -f "common-password" ] || mv common-password common-pass-old
cat << common > common-password
password  [success=1 default=ignore]  pam_unix.so obscure sha512
password  requisite     pam_deny.so
password  required      pam_permit.so
common
cd; systemctl restart sshd
if [[ $needpass ]];then
  echo "You need to change the password."
  read -p "Password: " -e PASS
  echo -e "$PASS\n$PASS\n" | passwd root
fi

echo "Installing required packages."
if [[ ! `type -P docker` ]]; then
APT="apt -y"
$APT install apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/$ID/gpg | apt-key add - 
add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/$ID $(lsb_release -cs) stable"
$APT update
apt-cache policy docker-ce
$APT install docker-ce
$APT clean; fi

echo "Installing OpenVPN."
apt-get install -y openvpn
opam=`find /usr -name openvpn*auth-pam.so`

cd /etc/openvpn
cat << ovpn > server.conf
port 1194
proto tcp
dev tun

topology subnet
server 10.10.0.0 255.255.0.0
ifconfig-pool-persist ipp.save

ca keys/ca.crt
dh keys/dh2048.pem
cert keys/server.crt
key keys/server.key

tls-cipher TLS-ECDHE-RSA-WITH-AES-128-GCM-SHA256
ncp-disable

username-as-common-name
verify-client-cert none
plugin $opam login
script-security 2

auth none
cipher none

push "verb 3"
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-renew"
push "block-outside-dns"
push "register-dns"
push "dhcp-option DNS 1.0.0.1"
push "dhcp-option DNS 1.0.0.1"

keepalive 5 60
tcp-nodelay
reneg-sec 0

persist-key
persist-tun

log-append log/openvpn.log
verb 3
ovpn

mkdir keys 2> /dev/null
cd keys

cat << ovpnca > ca.crt
-----BEGIN CERTIFICATE-----
MIIEZzCCA0+gAwIBAgIUH16Z5Nwl9x5QlYO3jVkCJ5I7PpkwDQYJKoZIhvcNAQEL
BQAweDELMAkGA1UEBhMCUEgxDzANBgNVBAgTBk1hbmlsYTEPMA0GA1UEBxMGUXVl
em9uMQowCAYDVQQKEwEtMQowCAYDVQQLEwEtMQ0wCwYDVQQDEwQtIENBMQ4wDAYD
VQQpEwVYLURDQjEQMA4GCSqGSIb3DQEJARYBLTAeFw0xODEyMDMxMjQ2MTZaFw0y
ODExMzAxMjQ2MTZaMHgxCzAJBgNVBAYTAlBIMQ8wDQYDVQQIEwZNYW5pbGExDzAN
BgNVBAcTBlF1ZXpvbjEKMAgGA1UEChMBLTEKMAgGA1UECxMBLTENMAsGA1UEAxME
LSBDQTEOMAwGA1UEKRMFWC1EQ0IxEDAOBgkqhkiG9w0BCQEWAS0wggEiMA0GCSqG
SIb3DQEBAQUAA4IBDwAwggEKAoIBAQC+DV1Dg3hpA2NFWgs6DJ1hmmeG1oi2AGKC
ZdsaT825IPTJEIFuD23J71NEKHm6kWQLRd2AR8696PyPm/TxSsBlqrrcnmiYrzp9
C+dgUQb71+hnwXvit7zhCeAjy2bj+mtgByCzuHSgNdpFftkw5ew42P6mhxmLSsUw
ba5HXf5MRUtpf67tHbtdS8ii6fVpl5wffOW/GPYyiXgLOXlXLa8sxR92UsFtYdWE
3fyi0kVMc93R8sOW1MTJhBYTxqA+3hrj0hHz0dV8bfjyCs+OhwA5T8cUtruRwa1r
eZNzcka2TfDz0/pIyrEiA4QD2dePJT2XRp3uUyu8a0bVeZ2YepJdAgMBAAGjgegw
geUwHQYDVR0OBBYEFJ+kIC+6Gq350o5VPbs5kwS25hSMMIG1BgNVHSMEga0wgaqA
FJ+kIC+6Gq350o5VPbs5kwS25hSMoXykejB4MQswCQYDVQQGEwJQSDEPMA0GA1UE
CBMGTWFuaWxhMQ8wDQYDVQQHEwZRdWV6b24xCjAIBgNVBAoTAS0xCjAIBgNVBAsT
AS0xDTALBgNVBAMTBC0gQ0ExDjAMBgNVBCkTBVgtRENCMRAwDgYJKoZIhvcNAQkB
FgEtghQfXpnk3CX3HlCVg7eNWQInkjs+mTAMBgNVHRMEBTADAQH/MA0GCSqGSIb3
DQEBCwUAA4IBAQAZ9nn4Z6wSzid+dBlSojEk547688U67idkTFLgShRQfqzAkcuS
ahk/W5gwM/YyGJL+y5JaW0d15dIr+cORAV4vUecrn9/5AS8AAph9UM3VpO9DRl0a
XHIxwzzi4N4mygMgeKdmbYLCOXkqtXEKLgX3hCntttnLEmWWqWfjgssfJd3KPdnd
myo2WMC20CZQ97d+4ga7TLTDr1vhO+H1YUpinURni0FgUp+rIZUUom+j+pDjWMXd
cYUmGUSiTJUo073hILdyyelCZ75cu5AfEAsCrJ10bGz99CKecoBbLRzR6ARgnrrS
n9q7bvX39TPdCLzlGsfdrT+NOvn9XU1zWyz6
-----END CERTIFICATE-----
ovpnca

cat << ovpnskey > server.key
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCptYUiwhQB52TT
O6R3/DkXyTq6rWumxKEAwzVxC5faBipHs4Fv5AjkDzgFWDgbqn5w0sKiXlJJpD7Z
bHhd2fL/PSIX3JH26Qnwn75JFJgNpbBInMVx9MjKeMaG90+HCaXPld9Gdni8CMtj
2L8CuUh3lzIa0fGQJcQoLxiGbI58zz1+acHTHrOfc8+vgMvk//TsBkm3uwj0tk+A
+2IhZ2lKdymhD1k381t9rBzKd2VhM0XHR9omU0sxIzIXEHo3l1ncjNdyRFR4L0Of
nBqF0ovAsYV8NtrM/5FUPbfkaC5+up3Yjx1y0EnTDxWjjUbDjqpU1fjhBksTNwou
ClXXmtZpAgMBAAECggEABX4LbgGL9jfP6ooum3d9PYjUrr/4EPCiKU0oCJ2Qb4zt
h16G3OErbH4VmQ6u2i5dYzde9zRIQ3veUNkS2C66j4oh9VW9H5mRKclxthnFhgOL
vf3c4gBDE1JvUmTknQEx7ZLzI+unoqZCNtwH6oWmk8A/7eBHihu+ynIjwA35Wo6o
8a+Zj1LeEFc83YAOxeklVefV3OvHaesv8da8mfcrq+s9xJR6zwIB6/zsYoLHp/n9
+Nnx/iz4BnuK3vLBKnOByEb8Aw4yD1j06X/zO1Gi1RWmFLZhbYTRw9vARf0Syjnr
29WY55QSCO3QFuLBVQya+ytB6mnDf5cMIzozFZbRgQKBgQDdZx99vde1xGQ8YpfM
iisfxszuXJe6do1G77APngYzYj8zEJ9DpAQPtRfeASvuu5mgjMcBxJdEwwqmO+mx
4eFEfycmZxFIP4peiuniCB97F5LPD+eVIM3E7u71QW55UeF6yvdzAdEjMLp0edJd
SZ15i4xoTDrye6RXcqdscM0fEQKBgQDEOnfcK+q7U3sXnehcaqcO9BRUoFdJdcJ0
83XBOqBhGynhGgDf7eB1bL8rLkyHku858nTqOv6/KfQschGljIwsUs3RoJkk5hW3
SAJlepPJPcL2WWzTgTI/N9ztJ1bK3Vfb/djA3rbHZ1PnND/lCLwzWSFcuI8/zmy2
FA79OLVx2QKBgQC903LenmxaPh4q3+WCy1waDJscK2szxf1vOoZbfYOXfr7tC21h
0zhgN0ZVY+/E6jfXvZvK2kFQBWIWEPxXNXGtBtAMTwY0SbZbRQMudwR2x0lqGxrV
c6C5Hprm0MjlX9zRKUBr7LzhTSAwSVqh/UH1Oj6SFfnceUH4cCc4BKb54QKBgAUK
B1f1HMMQwsF5gaUV7BJbPEZsE7HEP2knc2ex7LpxqyKnu0wE3NXHJCWku7xjjpcr
XctCFpasKiQWDdP1hwgAXF68xBIJgpdBVyZp/m+VkXMoGr5XvAWZlqfUccsl4gK5
Qx642XLHeYUfd2CXV9XtvQiXiL43u9z1KOlh0m8JAoGAbkgGepmMRk3bN56dK8rE
w8fZe0oSw1tYAaXkMQ5M1ulQ8l/zHEGy5FDq7BlanmeqUc9sTV2bp0pq+S9OVZCP
m/nV39+X7Jyj6653a/3Ce5PXOR/6UrsWeFjRAKItWHScJtcQZ2s+JyxlmPQDcJG3
JbXr5yY8k8EKMPR7RsMHrbU=
-----END PRIVATE KEY-----
ovpnskey

cat << ovpnsca > server.crt
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 1 (0x1)
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=PH, ST=Manila, L=Quezon, O=-, OU=-, CN=- CA/name=X-DCB/emailAddress=-
        Validity
            Not Before: Dec  3 12:46:22 2018 GMT
            Not After : Nov 30 12:46:22 2028 GMT
        Subject: C=PH, ST=Manila, L=Quezon, O=-, OU=-, CN=X-DCB/name=X-DCB/emailAddress=-
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                RSA Public-Key: (2048 bit)
                Modulus:
                    00:a9:b5:85:22:c2:14:01:e7:64:d3:3b:a4:77:fc:
                    39:17:c9:3a:ba:ad:6b:a6:c4:a1:00:c3:35:71:0b:
                    97:da:06:2a:47:b3:81:6f:e4:08:e4:0f:38:05:58:
                    38:1b:aa:7e:70:d2:c2:a2:5e:52:49:a4:3e:d9:6c:
                    78:5d:d9:f2:ff:3d:22:17:dc:91:f6:e9:09:f0:9f:
                    be:49:14:98:0d:a5:b0:48:9c:c5:71:f4:c8:ca:78:
                    c6:86:f7:4f:87:09:a5:cf:95:df:46:76:78:bc:08:
                    cb:63:d8:bf:02:b9:48:77:97:32:1a:d1:f1:90:25:
                    c4:28:2f:18:86:6c:8e:7c:cf:3d:7e:69:c1:d3:1e:
                    b3:9f:73:cf:af:80:cb:e4:ff:f4:ec:06:49:b7:bb:
                    08:f4:b6:4f:80:fb:62:21:67:69:4a:77:29:a1:0f:
                    59:37:f3:5b:7d:ac:1c:ca:77:65:61:33:45:c7:47:
                    da:26:53:4b:31:23:32:17:10:7a:37:97:59:dc:8c:
                    d7:72:44:54:78:2f:43:9f:9c:1a:85:d2:8b:c0:b1:
                    85:7c:36:da:cc:ff:91:54:3d:b7:e4:68:2e:7e:ba:
                    9d:d8:8f:1d:72:d0:49:d3:0f:15:a3:8d:46:c3:8e:
                    aa:54:d5:f8:e1:06:4b:13:37:0a:2e:0a:55:d7:9a:
                    d6:69
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:FALSE
            Netscape Cert Type: 
                SSL Server
            Netscape Comment: 
                Easy-RSA Generated Server Certificate
            X509v3 Subject Key Identifier: 
                CE:EC:8C:89:16:E3:7E:13:86:99:6B:C0:9D:FD:67:3E:9D:E0:B9:17
            X509v3 Authority Key Identifier: 
                keyid:9F:A4:20:2F:BA:1A:AD:F9:D2:8E:55:3D:BB:39:93:04:B6:E6:14:8C
                DirName:/C=PH/ST=Manila/L=Quezon/O=-/OU=-/CN=- CA/name=X-DCB/emailAddress=-
                serial:1F:5E:99:E4:DC:25:F7:1E:50:95:83:B7:8D:59:02:27:92:3B:3E:99

            X509v3 Extended Key Usage: 
                TLS Web Server Authentication
            X509v3 Key Usage: 
                Digital Signature, Key Encipherment
            X509v3 Subject Alternative Name: 
                DNS:X-DCB
    Signature Algorithm: sha256WithRSAEncryption
         6a:62:6a:dd:97:d4:fd:1b:4f:78:7a:79:13:0b:0c:cc:72:21:
         0e:c8:a3:09:63:d8:7e:91:43:2f:ad:d4:69:6c:df:19:6f:08:
         cb:c8:e7:3f:5f:d9:51:be:57:53:82:37:35:5e:75:21:b4:36:
         d6:e7:59:1e:53:86:73:0b:f0:5c:ed:50:3c:3e:be:33:04:e9:
         71:6c:84:c9:a3:ad:0b:25:9d:c3:4a:f0:66:3e:a6:6e:4f:b3:
         a4:33:a8:c1:f2:84:6b:5e:6c:c9:09:de:9c:55:e0:24:0e:79:
         c9:dc:10:ef:9a:05:e4:1b:54:e7:b4:87:82:b6:3e:b3:ab:84:
         ea:b4:cf:22:e3:df:9f:7a:03:d4:38:ac:a0:83:ef:25:ed:1f:
         04:f1:7d:a5:87:4a:32:06:2a:67:1f:9b:cc:e9:54:17:d8:6f:
         5b:0d:c8:ce:29:5f:37:11:a5:95:af:69:15:21:72:84:f6:41:
         db:d7:55:e6:9a:49:3f:2d:fd:eb:78:85:e6:cb:b4:3d:00:03:
         16:de:a1:be:18:73:a1:7f:2c:f3:0f:74:29:ab:d1:3e:3f:48:
         80:21:e9:7a:5a:00:2e:0e:7f:9b:56:31:66:f4:ca:08:c2:16:
         15:b7:ba:96:ef:28:62:3d:09:7e:99:00:9b:bc:1c:0e:0f:29:
         b0:ce:6b:94
-----BEGIN CERTIFICATE-----
MIIE0TCCA7mgAwIBAgIBATANBgkqhkiG9w0BAQsFADB4MQswCQYDVQQGEwJQSDEP
MA0GA1UECBMGTWFuaWxhMQ8wDQYDVQQHEwZRdWV6b24xCjAIBgNVBAoTAS0xCjAI
BgNVBAsTAS0xDTALBgNVBAMTBC0gQ0ExDjAMBgNVBCkTBVgtRENCMRAwDgYJKoZI
hvcNAQkBFgEtMB4XDTE4MTIwMzEyNDYyMloXDTI4MTEzMDEyNDYyMloweTELMAkG
A1UEBhMCUEgxDzANBgNVBAgTBk1hbmlsYTEPMA0GA1UEBxMGUXVlem9uMQowCAYD
VQQKEwEtMQowCAYDVQQLEwEtMQ4wDAYDVQQDEwVYLURDQjEOMAwGA1UEKRMFWC1E
Q0IxEDAOBgkqhkiG9w0BCQEWAS0wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
AoIBAQCptYUiwhQB52TTO6R3/DkXyTq6rWumxKEAwzVxC5faBipHs4Fv5AjkDzgF
WDgbqn5w0sKiXlJJpD7ZbHhd2fL/PSIX3JH26Qnwn75JFJgNpbBInMVx9MjKeMaG
90+HCaXPld9Gdni8CMtj2L8CuUh3lzIa0fGQJcQoLxiGbI58zz1+acHTHrOfc8+v
gMvk//TsBkm3uwj0tk+A+2IhZ2lKdymhD1k381t9rBzKd2VhM0XHR9omU0sxIzIX
EHo3l1ncjNdyRFR4L0OfnBqF0ovAsYV8NtrM/5FUPbfkaC5+up3Yjx1y0EnTDxWj
jUbDjqpU1fjhBksTNwouClXXmtZpAgMBAAGjggFjMIIBXzAJBgNVHRMEAjAAMBEG
CWCGSAGG+EIBAQQEAwIGQDA0BglghkgBhvhCAQ0EJxYlRWFzeS1SU0EgR2VuZXJh
dGVkIFNlcnZlciBDZXJ0aWZpY2F0ZTAdBgNVHQ4EFgQUzuyMiRbjfhOGmWvAnf1n
Pp3guRcwgbUGA1UdIwSBrTCBqoAUn6QgL7oarfnSjlU9uzmTBLbmFIyhfKR6MHgx
CzAJBgNVBAYTAlBIMQ8wDQYDVQQIEwZNYW5pbGExDzANBgNVBAcTBlF1ZXpvbjEK
MAgGA1UEChMBLTEKMAgGA1UECxMBLTENMAsGA1UEAxMELSBDQTEOMAwGA1UEKRMF
WC1EQ0IxEDAOBgkqhkiG9w0BCQEWAS2CFB9emeTcJfceUJWDt41ZAieSOz6ZMBMG
A1UdJQQMMAoGCCsGAQUFBwMBMAsGA1UdDwQEAwIFoDAQBgNVHREECTAHggVYLURD
QjANBgkqhkiG9w0BAQsFAAOCAQEAamJq3ZfU/RtPeHp5EwsMzHIhDsijCWPYfpFD
L63UaWzfGW8Iy8jnP1/ZUb5XU4I3NV51IbQ21udZHlOGcwvwXO1QPD6+MwTpcWyE
yaOtCyWdw0rwZj6mbk+zpDOowfKEa15syQnenFXgJA55ydwQ75oF5BtU57SHgrY+
s6uE6rTPIuPfn3oD1DisoIPvJe0fBPF9pYdKMgYqZx+bzOlUF9hvWw3IzilfNxGl
la9pFSFyhPZB29dV5ppJPy3963iF5su0PQADFt6hvhhzoX8s8w90KavRPj9IgCHp
eloALg5/m1YxZvTKCMIWFbe6lu8oYj0JfpkAm7wcDg8psM5rlA==
-----END CERTIFICATE-----
ovpnsca

cat << ovpndh > dh2048.pem
-----BEGIN DH PARAMETERS-----
MIIBCAKCAQEAr5+h3sW+y6/9ZZyitYwQOAZwv5umOCJdMMUtT4CVBzskKu6v6Lua
XSAInneN8Qj+fo8eAUWpu4pZUrhlH5XlQLpjQv0WBq8YUTMiigCqKn+WvrT0886U
DMdBt6TnpR3Hp5tLqCwbq7AjI6khxYJly+GIqs1W9TSYbjGaCjyTLMil8ckZHjIk
a/Uiq/JhNZV2ZsRrUvQP/QhNDwICG1dbKc79L2+AaLFj6R1128wIa6X02sg9jyfH
Eetj2JwwZggp3O/m8efv/MUYAy7OqpziWhllxT0ZGMAdzGmx1O9mdkXXxf+dmNNW
9wj2aOTAWkwqBGP8FrcYywTeInJ9XX9OKwIBAg==
-----END DH PARAMETERS-----
ovpndh

systemctl restart openvpn@server; cd

echo "Installing socksproxy."
loc=/etc/socksproxy
mkdir $loc 2> /dev/null

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

echo "<font color=\"green\">Dexter Cellona Banawon (X-DCB)</font>" > $loc/message

web=$loc/web
mkdir $web 2> /dev/null

cat << ovpnconf > $web/$MYIP.ovpn
client
dev tun
proto tcp
remote $MYIP 1194
route-method exe
mute-replay-warnings
http-proxy $MYIP 8880
verb 3
auth-user-pass
cipher none
auth none
<ca>
-----BEGIN CERTIFICATE-----
MIIEZzCCA0+gAwIBAgIUH16Z5Nwl9x5QlYO3jVkCJ5I7PpkwDQYJKoZIhvcNAQEL
BQAweDELMAkGA1UEBhMCUEgxDzANBgNVBAgTBk1hbmlsYTEPMA0GA1UEBxMGUXVl
em9uMQowCAYDVQQKEwEtMQowCAYDVQQLEwEtMQ0wCwYDVQQDEwQtIENBMQ4wDAYD
VQQpEwVYLURDQjEQMA4GCSqGSIb3DQEJARYBLTAeFw0xODEyMDMxMjQ2MTZaFw0y
ODExMzAxMjQ2MTZaMHgxCzAJBgNVBAYTAlBIMQ8wDQYDVQQIEwZNYW5pbGExDzAN
BgNVBAcTBlF1ZXpvbjEKMAgGA1UEChMBLTEKMAgGA1UECxMBLTENMAsGA1UEAxME
LSBDQTEOMAwGA1UEKRMFWC1EQ0IxEDAOBgkqhkiG9w0BCQEWAS0wggEiMA0GCSqG
SIb3DQEBAQUAA4IBDwAwggEKAoIBAQC+DV1Dg3hpA2NFWgs6DJ1hmmeG1oi2AGKC
ZdsaT825IPTJEIFuD23J71NEKHm6kWQLRd2AR8696PyPm/TxSsBlqrrcnmiYrzp9
C+dgUQb71+hnwXvit7zhCeAjy2bj+mtgByCzuHSgNdpFftkw5ew42P6mhxmLSsUw
ba5HXf5MRUtpf67tHbtdS8ii6fVpl5wffOW/GPYyiXgLOXlXLa8sxR92UsFtYdWE
3fyi0kVMc93R8sOW1MTJhBYTxqA+3hrj0hHz0dV8bfjyCs+OhwA5T8cUtruRwa1r
eZNzcka2TfDz0/pIyrEiA4QD2dePJT2XRp3uUyu8a0bVeZ2YepJdAgMBAAGjgegw
geUwHQYDVR0OBBYEFJ+kIC+6Gq350o5VPbs5kwS25hSMMIG1BgNVHSMEga0wgaqA
FJ+kIC+6Gq350o5VPbs5kwS25hSMoXykejB4MQswCQYDVQQGEwJQSDEPMA0GA1UE
CBMGTWFuaWxhMQ8wDQYDVQQHEwZRdWV6b24xCjAIBgNVBAoTAS0xCjAIBgNVBAsT
AS0xDTALBgNVBAMTBC0gQ0ExDjAMBgNVBCkTBVgtRENCMRAwDgYJKoZIhvcNAQkB
FgEtghQfXpnk3CX3HlCVg7eNWQInkjs+mTAMBgNVHRMEBTADAQH/MA0GCSqGSIb3
DQEBCwUAA4IBAQAZ9nn4Z6wSzid+dBlSojEk547688U67idkTFLgShRQfqzAkcuS
ahk/W5gwM/YyGJL+y5JaW0d15dIr+cORAV4vUecrn9/5AS8AAph9UM3VpO9DRl0a
XHIxwzzi4N4mygMgeKdmbYLCOXkqtXEKLgX3hCntttnLEmWWqWfjgssfJd3KPdnd
myo2WMC20CZQ97d+4ga7TLTDr1vhO+H1YUpinURni0FgUp+rIZUUom+j+pDjWMXd
cYUmGUSiTJUo073hILdyyelCZ75cu5AfEAsCrJ10bGz99CKecoBbLRzR6ARgnrrS
n9q7bvX39TPdCLzlGsfdrT+NOvn9XU1zWyz6
-----END CERTIFICATE-----
</ca>
ovpnconf

docker run -d --name socksproxyX \
  -v $loc:/conf \
  --net host --cap-add NET_ADMIN xdcb/smart-bypass:socksproxyX

echo "Adding service: socksproxy"
cat << service > /etc/systemd/system/socksproxy.service
[Unit]
Description=Socks Proxy
Wants=network.target
After=network.target
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/docker start socksproxyX
ExecStop=/usr/bin/docker stop socksproxyX
[Install]
WantedBy=network.target
service

systemctl daemon-reload
systemctl enable socksproxy
systemctl start socksproxy

cat << service > /etc/systemd/system/iptab.service
[Unit]
Description=OpenVPN IP Table
Wants=network.target
After=network.target
DefaultDependencies=no
[Service]
ExecStart=/sbin/iptab
Type=oneshot
RemainAfterExit=yes
[Install]
WantedBy=network.target
service

cat << 'iptabc' > /sbin/iptab
#!/bin/bash
INET="$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)"
iptables -F
iptables -X
iptables -F -t nat
iptables -X -t nat
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t nat -I POSTROUTING -o $INET -j MASQUERADE
iptables -A INPUT -j ACCEPT
iptables -A FORWARD -j ACCEPT
iptables -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -m state --state ESTABLISHED --sport 22 -j ACCEPT
iptables -A INPUT -p udp -m state --state ESTABLISHED --sport 53 -j ACCEPT
iptables -A OUTPUT -p udp -m state --state NEW,ESTABLISHED --dport 53 -j ACCEPT
iptables -A INPUT -p tcp -m state --state NEW,ESTABLISHED --dport 22 -j ACCEPT
iptables -t filter -A FORWARD -j REJECT --reject-with icmp-port-unreachable
iptabc

chmod a+x /sbin/iptab

echo "Installing BadVPN."
docker run -d --restart always --name badvpn \
 --net host --cap-add NET_ADMIN \
 --entrypoint "badvpn-udpgw" \
 xdcb/vpn:badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 1000 --max-connections-for-client 10

echo "Adding menu 'xdcb'."
bin=/usr/local/bin
cat << 'menu' > $bin/xdcb
#!/bin/bash
add() {
cat << msg

 ================================
|         Create Account         |
 ================================
| Note: Leave duration empty
|       for non-expiring account
msg
read -p "    Username : " -e USER
read -p "    Password : " -e PASS
read -p "    Duration : " -e DAYS
exp=`date -d "+$DAYS days" +%F`
[ $DAYS ] && ex="-e $exp"
useradd $ex -NM -s /bin/false $USER 2> /dev/null
echo -e "$PASS\n$PASS\n" | passwd $USER 2> /dev/null
clear
cat << info
~ Account Info ~
Username : $USER
Password : $PASS
Duration : `[ $DAYS ] && echo "$DAYS days" || echo "Lifetime"`

~ Server Ports ~
OHP :
info
IFS=$'\n' arr=`cat /etc/socksproxy/server.conf`
for line in $arr; do
	[ `grep "^sport" <<< "$line"` ] && s=$((line))
	[ `grep "^timer" <<< "$line"` ] && t=$((line))
	if [[ $t && $s ]]; then
		[ $t -ge 30 ] && t+="s" || t="No"
		echo "   - $s ($t timer)"
		unset t s
	fi
done
echo "SSH :"
netstat -tulpn | egrep "tcp .+ssh" | egrep -o ":[0-9]{2,}" | sed -e "s/:/   - /g"
exit 0
}

del() {
echo "== ! Delete Account ! =="
read -p "Username : " -e USER
userdel -f -r $USER 2> /dev/null
echo "$USER deleted"
exit 0
}

list() {
cat << msg

 ======================
|   List of Accounts   |
 ======================
msg
egrep -v 'root|:[\*!]' /etc/shadow | sed -e 's|:.*||g;s|^|   - |g' -
exit 0
}
case $1 in
accadd)
	add;;
accdel)
	del;;
acclist)
	list;;
esac
cat << msg

 ==================
|   Menu Options   |
 ==================
     - accadd
     - acclist
     - accdel
| Usage: xdcb [option]

Credits: Dexter Cellona Banawon (X-DCB)
msg
exit 0
menu

chmod a+x $bin/*

cd; echo "Optimizing server."
cat << sysctl > /etc/sysctl.d/xdcb.conf
net.ipv4.ip_forward=1
net.ipv4.tcp_rmem=65535 131072 4194304
net.ipv4.tcp_wmem=65535 131072 4194304
net.ipv4.ip_default_ttl=50
net.ipv4.tcp_congestion_control=bbr
net.core.wmem_default=262144
net.core.wmem_max=4194304
net.core.rmem_default=262144
net.core.rmem_max=4194304
net.core.netdev_budget=600
net.core.default_qdisc=fq
net.ipv6.conf.all.accept_ra=2
sysctl
sysctl --system

clear
cat << info | tee ~/socksproxylog.txt

`[ $PASS ] && echo -e "| New Password for 'root':
|    $PASS"`
  ====================================
| Installation finished.              |
| Service Name: socksproxy            |
| Ports: 80 (SSH), 8880 (OpenVPN)     |
| Log output: /root/socksproxylog.txt |
| =================================== |
| Use "xdcb" for the menu             |
| Contact me @                        |
|    - https://fb.me/theMovesFever    |
 =====================================
 
info
rm -f $0 ~/.bash_history
history -c
echo '' > /var/log/syslog
exit 0
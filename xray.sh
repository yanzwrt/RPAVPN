#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition V1.0
# Author  : Rakha-VPN
# (C) Copyright 2025
# =========================================

# ======= Warna Terminal =======
red='\e[1;31m'
green='\e[0;32m'
yellow='\e[1;33m'
tyblue='\e[1;36m'
purple='\e[0;35m'
NC='\e[0m'

red() { echo -e "\\033[31;1m${*}\\033[0m"; }
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
yellow() { echo -e "\\033[33;1m${*}\\033[0m"; }
tyblue() { echo -e "\\033[36;1m${*}\\033[0m"; }
purple() { echo -e "\\033[35;1m${*}\\033[0m"; }

# ======= Server URL =======
export Server_URL="raw.githubusercontent.com/yanzwrt/RPAVPN/main"

clear
echo -e "[ ${green}INFO${NC} ] Mengambil tanggal dari server..."
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=$(date +"%Y-%m-%d" -d "$dateFromServer")

# ======= IP Server =======
MYIP=$(curl -sS ipv4.icanhazip.com)
echo -e "[ ${green}INFO${NC} ] IP Server: $MYIP"

# ======= Domain =======
domain=$(cat /root/domain)

# ======= Update & Install Paket =======
echo -e "[ ${green}INFO${NC} ] Memperbarui sistem dan menginstall paket..."
apt update -y
apt upgrade -y
apt install socat python python3 curl wget sed nano unzip zip pwgen openssl netcat cron bash-completion ntpdate chrony apt-transport-https gnupg gnupg2 gnupg1 dnsutils lsb-release xz-utils -y

# ======= Set Waktu =======
ntpdate pool.ntp.org
timedatectl set-ntp true
systemctl enable chronyd && systemctl restart chronyd
timedatectl set-timezone Asia/Jakarta
chronyc sourcestats -v
chronyc tracking -v
date

# ======= Folder =======
mkdir -p /var/log/xray
chmod +x /var/log/xray
mkdir -p /usr/local/etc/xray
mkdir -p /home/vps/public_html

# ======= Install XRAY Core =======
echo -e "[ ${green}INFO${NC} ] Mengunduh XRAY Core..."
wget -O /usr/local/bin/xray "https://raw.githubusercontent.com/yanzwrt/RPAVPN/main/xray.linux.64bit"
chmod +x /usr/local/bin/xray

# ======= Generate Sertifikat =======
echo -e "[ ${green}INFO${NC} ] Mengatur sertifikat SSL..."
mkdir -p /root/.acme.sh
curl https://raw.githubusercontent.com/yanzwrt/RPAVPN/main/acme.sh -o /root/.acme.sh/acme.sh
chmod +x /root/.acme.sh/acme.sh
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
/root/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /usr/local/etc/xray/xray.crt --keypath /usr/local/etc/xray/xray.key --ecc

# ======= Set UUID =======
uuid=$(cat /proc/sys/kernel/random/uuid)

# ======= Konfigurasi XRAY =======
echo -e "[ ${green}INFO${NC} ] Menulis konfigurasi XRAY..."

# VMESS TLS
cat> /usr/local/etc/xray/config.json << END
{
  "log": {"access": "/var/log/xray/access.log","error": "/var/log/xray/error.log","loglevel": "info"},
  "inbounds": [
    {
      "port": 1311,
      "listen": "127.0.0.1",
      "protocol": "vmess",
      "settings": {"clients":[{"id": "${uuid}","alterId":0,"level":0,"email":""}]},
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "tlsSettings": {"serverName": "${domain}"},
        "wsSettings": {"acceptProxyProtocol": true,"path": "/vmess"}
      }
    }
  ],
  "outbounds":[{"protocol":"freedom","settings":{}},{"protocol":"blackhole","settings":{},"tag":"blocked"}]
}
END

# VMESS NON-TLS
cat> /usr/local/etc/xray/none.json << END
{
  "log":{"access":"/var/log/xray/access.log","error":"/var/log/xray/error.log","loglevel":"info"},
  "inbounds":[
    {"listen":"127.0.0.1","port":23456,"protocol":"vmess","settings":{"clients":[{"id":"${uuid}","alterId":0,"email":""}],"decryption":"none"},"streamSettings":{"network":"ws","security":"none","wsSettings":{"path":"/vmess"}}}
  ],
  "outbounds":[{"protocol":"freedom","settings":{}},{"protocol":"blackhole","settings":{},"tag":"blocked"}]
}
END

# VLESS TLS
cat> /usr/local/etc/xray/vless.json << END
{
  "log":{"access":"/var/log/xray/access2.log","error":"/var/log/xray/error.log","loglevel":"info"},
  "inbounds":[
    {"port":1312,"listen":"127.0.0.1","protocol":"vless","settings":{"clients":[{"id":"${uuid}","level":0,"email":""}],"decryption":"none"},"streamSettings":{"network":"ws","security":"tls","tlsSettings":{"serverName":"${domain}"},"wsSettings":{"acceptProxyProtocol":true,"path":"/vless"}}}
  ],
  "outbounds":[{"protocol":"freedom","settings":{}},{"protocol":"blackhole","settings":{},"tag":"blocked"}]
}
END

# VLESS NON-TLS
cat> /usr/local/etc/xray/vnone.json << END
{
  "log":{"access":"/var/log/xray/access2.log","error":"/var/log/xray/error.log","loglevel":"info"},
  "inbounds":[{"listen":"127.0.0.1","port":14016,"protocol":"vless","settings":{"clients":[{"id":"${uuid}","level":0,"email":""}],"decryption":"none"},"streamSettings":{"network":"ws","security":"none","wsSettings":{"path":"/vless"}}}],
  "outbounds":[{"protocol":"freedom","settings":{}},{"protocol":"blackhole","settings":{},"tag":"blocked"}]
}
END

# TROJAN WS TLS
cat> /usr/local/etc/xray/trojanws.json << END
{
  "log":{"access":"/var/log/xray/access3.log","error":"/var/log/xray/error.log","loglevel":"info"},
  "inbounds":[{"port":1313,"listen":"127.0.0.1","protocol":"trojan","settings":{"clients":[{"password":"${uuid}","level":0,"email":""}]},"streamSettings":{"network":"ws","security":"tls","tlsSettings":{"serverName":"${domain}"},"wsSettings":{"acceptProxyProtocol":true,"path":"/trojan"}}}],
  "outbounds":[{"protocol":"freedom","settings":{}},{"protocol":"blackhole","settings":{},"tag":"blocked"}]
}
END

# TROJAN WS NON-TLS
cat> /usr/local/etc/xray/trnone.json << END
{
  "log":{"access":"/var/log/xray/access3.log","error":"/var/log/xray/error.log","loglevel":"info"},
  "inbounds":[{"listen":"127.0.0.1","port":25432,"protocol":"trojan","settings":{"clients":[{"password":"${uuid}","level":0,"email":""}],"decryption":"none"},"streamSettings":{"network":"ws","security":"none","wsSettings":{"path":"/trojan"}}}],
  "outbounds":[{"protocol":"freedom","settings":{}},{"protocol":"blackhole","settings":{},"tag":"blocked"}]
}
END

# TROJAN TCP XTLS
cat> /usr/local/etc/xray/xtrojan.json << END
{
  "log":{"access":"/var/log/xray/access5.log","error":"/var/log/xray/error.log","loglevel":"info"},
  "inbounds":[{"port":443,"protocol":"trojan","settings":{"clients":[{"id":"${uuid}","flow":"xtls-rprx-direct","level":0,"email":""}],"decryption":"none"},"streamSettings":{"network":"tcp","security":"xtls","xtlsSettings":{"minVersion":"1.2","alpn":["http/1.1","h2"],"certificates":[{"certificateFile":"/usr/local/etc/xray/xray.crt","keyFile":"/usr/local/etc/xray/xray.key"}]}}}]
}
END

# TROJAN TCP
cat> /usr/local/etc/xray/trojan.json << END
{
  "log":{"access":"/var/log/xray/access4.log","error":"/var/log/xray/error.log","loglevel":"info"},
  "inbounds":[{"port":1310,"listen":"127.0.0.1","protocol":"trojan","settings":{"clients":[{"id":"${uuid}","password":"xxxxx"}]},"streamSettings":{"network":"tcp","security":"none","tcpSettings":{"acceptProxyProtocol":true}}}],
  "outbounds":[{"protocol":"freedom","settings":{}},{"protocol":"blackhole","settings":{},"tag":"blocked"}]
}
END

# ======= Service XRAY =======
echo -e "[ ${green}INFO${NC} ] Membuat systemd service..."
rm -rf /etc/systemd/system/xray.service.d
rm -rf /etc/systemd/system/xray@.service.d

# xray.service
cat> /etc/systemd/system/xray.service << END
[Unit]
Description=XRAY-Websocket Service
After=network.target nss-lookup.target

[Service]
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /usr/local/etc/xray/config.json
Restart=on-failure
RestartSec=3s

[Install]
WantedBy=multi-user.target
END

# xray@.service
cat> /etc/systemd/system/xray@.service << END
[Unit]
Description=XRAY-Websocket Service
After=network.target nss-lookup.target

[Service]
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /usr/local/etc/xray/%i.json
Restart=on-failure
RestartSec=3s

[Install]
WantedBy=multi-user.target
END

# ======= Nginx Config =======
echo -e "[ ${green}INFO${NC} ] Membuat konfigurasi Nginx..."
cat >/etc/nginx/conf.d/xray.conf << EOF
server {
    listen 80;
    server_name $domain;

    location / {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:14016;
        proxy_http_version 1.1;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;
    }

    location = /vmess-ntls {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:23456;
        proxy_http_version 1.1;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;
    }

    location = /trojan-ntls {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:25432;
        proxy_http_version 1.1;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;
    }
}
EOF

systemctl daemon-reload
systemctl enable nginx
systemctl restart nginx

# ======= Start Semua Service XRAY =======
for svc in "" none vless vnone trojanws trnone xtrojan trojan; do
    echo -e "[ ${green}INFO${NC} ] Mengaktifkan xray@${svc}.service"
    systemctl enable xray@${svc}.service 2>/dev/null
    systemctl start xray@${svc}.service 2>/dev/null
    systemctl restart xray@${svc}.service 2>/dev/null
done

systemctl enable xray.service
systemctl start xray.service
systemctl restart xray.service

# ======= Download Script Helper =======
cd /usr/bin
echo -e "[ ${green}INFO${NC} ] Mengunduh script helper..."
for skrip in add-ws cek-ws del-ws renew-ws user-ws trial-ws \
             add-vless cek-vless del-vless renew-vless user-vless trial-vless \
             add-tr cek-tr del-tr renew-tr user-tr trial-tr \
             add-xrt cek-xrt del-xrt renew-xrt user-xrt trial-xrt \
             add-xtr cek-xtr del-xtr renew-xtr user-xtr trial-xtr; do
    wget -O $skrip "https://${Server_URL}/$skrip.sh" && chmod +x $skrip
done

echo -e "[ ${green}DONE${NC} ] Instalasi XRAY selesai!"

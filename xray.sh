#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition V1.0
# Auther  : Rakha-VPN
# (C) Copyright 2025
# =========================================

red='\e[1;31m'
green='\e[0;32m'
purple='\e[0;35m'
orange='\e[0;33m'
NC='\e[0m'
export Server_URL="raw.githubusercontent.com/yanzwrt/RPAVPN/main"

clear
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=$(date +"%Y-%m-%d" -d "$dateFromServer")

# Ambil IP publik
MYIP=$(curl -sS ifconfig.me)

# Warna tambahan (kalau mau dipakai)
yell='\e[1;33m'
tyblue='\e[1;36m'
purplef() { echo -e "\\033[35;1m${*}\\033[0m"; }
tybluef() { echo -e "\\033[36;1m${*}\\033[0m"; }
yellowf() { echo -e "\\033[33;1m${*}\\033[0m"; }
greenf() { echo -e "\\033[32;1m${*}\\033[0m"; }
redf() { echo -e "\\033[31;1m${*}\\033[0m"; }

# Pastikan domain sudah diset
if [ ! -f /root/domain ]; then
  echo -e "${red}File /root/domain tidak ditemukan. Jalankan setup.sh dulu untuk set domain.${NC}"
  exit 1
fi

domain=$(cat /root/domain)

echo -e ""
echo -e "[ ${green}INFO${NC} ] Instalasi XRAY Core dimulai untuk domain: ${green}${domain}${NC}"
sleep 1

# Update & install package yang diperlukan
apt update -y
apt upgrade -y
apt install -y socat curl wget sed nano python3 zip pwgen openssl netcat cron \
  xz-utils apt-transport-https gnupg gnupg2 gnupg1 dnsutils lsb-release bash-completion ntpdate

# Sinkron waktu (biar SSL & acme gak rewel)
ntpdate pool.ntp.org
apt -y install chrony
timedatectl set-ntp true
systemctl enable chronyd >/dev/null 2>&1 || true
systemctl restart chronyd >/dev/null 2>&1 || true
systemctl enable chrony >/dev/null 2>&1 || true
systemctl restart chrony >/dev/null 2>&1 || true
timedatectl set-timezone Asia/Jakarta
date

# Folder log XRAY
mkdir -p /var/log/xray
chmod 755 /var/log/xray

# Folder konfigurasi XRAY
mkdir -p /usr/local/etc/xray

# Download XRAY Core (binary) dari repo kamu
echo -e "[ ${green}INFO${NC} ] Mengunduh binary XRAY..."
wget -O /usr/local/bin/xray "https://${Server_URL}/xray.linux.64bit"
chmod +x /usr/local/bin/xray

# Generate SSL dengan acme.sh (Let's Encrypt)
echo -e "[ ${green}INFO${NC} ] Menghasilkan sertifikat SSL dengan acme.sh..."
mkdir -p /root/.acme.sh
curl -sS "https://${Server_URL}/acme.sh" -o /root/.acme.sh/acme.sh
chmod +x /root/.acme.sh/acme.sh
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue -d "$domain" --standalone -k ec-256
/root/.acme.sh/acme.sh --installcert -d "$domain" \
  --fullchainpath /usr/local/etc/xray/xray.crt \
  --keypath /usr/local/etc/xray/xray.key --ecc

# Nginx web root untuk YAML dsb
mkdir -p /home/vps/public_html

# UUID awal (hanya default, user baru akan ditambah lewat add-*.sh)
uuid=$(cat /proc/sys/kernel/random/uuid)

########################
#  KONFIGURASI XRAY   #
########################

# === VMESS TLS (WS) ===
cat > /usr/local/etc/xray/config.json << END
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "port": 1311,
      "listen": "127.0.0.1",
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "${uuid}",
            "alterId": 0,
            "level": 0,
            "email": ""
#tls
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "acceptProxyProtocol": true,
          "path": "/vmess"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "ip": [
          "0.0.0.0/8",
          "10.0.0.0/8",
          "100.64.0.0/10",
          "169.254.0.0/16",
          "172.16.0.0/12",
          "192.0.0.0/24",
          "192.0.2.0/24",
          "192.168.0.0/16",
          "198.18.0.0/15",
          "198.51.100.0/24",
          "203.0.113.0/24",
          "::1/128",
          "fc00::/7",
          "fe80::/10"
        ],
        "outboundTag": "blocked"
      }
    ]
  },
  "stats": {},
  "api": {
    "services": [
      "StatsService"
    ],
    "tag": "api"
  },
  "policy": {
    "levels": {
      "0": {
        "statsUserDownlink": true,
        "statsUserUplink": true
      }
    },
    "system": {
      "statsInboundUplink": true,
      "statsInboundDownlink": true
    }
  }
}
END

# === VMESS NON-TLS (WS) ===
cat > /usr/local/etc/xray/none.json << END
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": 10085,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "127.0.0.1"
      },
      "tag": "api"
    },
    {
      "listen": "127.0.0.1",
      "port": 23456,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "${uuid}",
            "alterId": 0,
            "email": ""
#none
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "path": "/vmess",
          "headers": {
            "Host": ""
          }
        },
        "quicSettings": {},
        "sockopt": {
          "mark": 0,
          "tcpFastOpen": true
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "ip": [
          "0.0.0.0/8",
          "10.0.0.0/8",
          "100.64.0.0/10",
          "169.254.0.0/16",
          "172.16.0.0/12",
          "192.0.0.0/24",
          "192.0.2.0/24",
          "192.168.0.0/16",
          "198.18.0.0/15",
          "198.51.100.0/24",
          "203.0.113.0/24",
          "::1/128",
          "fc00::/7",
          "fe80::/10"
        ],
        "outboundTag": "blocked"
      }
    ]
  },
  "stats": {},
  "api": {
    "services": [
      "StatsService"
    ],
    "tag": "api"
  },
  "policy": {
    "levels": {
      "0": {
        "statsUserDownlink": true,
        "statsUserUplink": true
      }
    },
    "system": {
      "statsInboundUplink": true,
      "statsInboundDownlink": true,
      "statsOutboundUplink": true,
      "statsOutboundDownlink": true
    }
  }
}
END

# === VLESS TLS (WS) ===
cat > /usr/local/etc/xray/vless.json << END
{
  "log": {
    "access": "/var/log/xray/access2.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "port": 1312,
      "listen": "127.0.0.1",
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${uuid}",
            "level": 0,
            "email": ""
#tls
          }
        ],
        "decryption": "none"
      },
      "encryption": "none",
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "acceptProxyProtocol": true,
          "path": "/vless"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "ip": [
          "0.0.0.0/8",
          "10.0.0.0/8",
          "100.64.0.0/10",
          "169.254.0.0/16",
          "172.16.0.0/12",
          "192.0.0.0/24",
          "192.0.2.0/24",
          "192.168.0.0/16",
          "198.18.0.0/15",
          "198.51.100.0/24",
          "203.0.113.0/24",
          "::1/128",
          "fc00::/7",
          "fe80::/10"
        ],
        "outboundTag": "blocked"
      }
    ]
  },
  "stats": {},
  "api": {
    "services": [
      "StatsService"
    ],
    "tag": "api"
  },
  "policy": {
    "levels": {
      "0": {
        "statsUserDownlink": true,
        "statsUserUplink": true
      }
    },
    "system": {
      "statsInboundUplink": true,
      "statsInboundDownlink": true
    }
  }
}
END

# === VLESS NON-TLS (WS) ===
cat > /usr/local/etc/xray/vnone.json << END
{
  "log": {
    "access": "/var/log/xray/access2.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": 10085,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "127.0.0.1"
      },
      "tag": "api"
    },
    {
      "listen": "127.0.0.1",
      "port": 14016,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${uuid}",
            "level": 0,
            "email": ""
#none
          }
        ],
        "decryption": "none"
      },
      "encryption": "none",
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "path": "/vless",
          "headers": {
            "Host": ""
          }
        },
        "quicSettings": {},
        "sockopt": {
          "mark": 0,
          "tcpFastOpen": true
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "ip": [
          "0.0.0.0/8",
          "10.0.0.0/8",
          "100.64.0.0/10",
          "169.254.0.0/16",
          "172.16.0.0/12",
          "192.0.0.0/24",
          "192.0.2.0/24",
          "192.168.0.0/16",
          "198.18.0.0/15",
          "198.51.100.0/24",
          "203.0.113.0/24",
          "::1/128",
          "fc00::/7",
          "fe80::/10"
        ],
        "outboundTag": "blocked"
      }
    ]
  },
  "stats": {},
  "api": {
    "services": [
      "StatsService"
    ],
    "tag": "api"
  },
  "policy": {
    "levels": {
      "0": {
        "statsUserDownlink": true,
        "statsUserUplink": true
      }
    },
    "system": {
      "statsInboundUplink": true,
      "statsInboundDownlink": true,
      "statsOutboundUplink": true,
      "statsOutboundDownlink": true
    }
  }
}
END

# === TROJAN WS TLS ===
cat > /usr/local/etc/xray/trojanws.json << END
{
  "log": {
    "access": "/var/log/xray/access3.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "port": 1313,
      "listen": "127.0.0.1",
      "protocol": "trojan",
      "settings": {
        "clients": [
          {
            "password": "${uuid}",
            "level": 0,
            "email": ""
#tr
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "acceptProxyProtocol": true,
          "path": "/trojan"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "ip": [
          "0.0.0.0/8",
          "10.0.0.0/8",
          "100.64.0.0/10",
          "169.254.0.0/16",
          "172.16.0.0/12",
          "192.0.0.0/24",
          "192.0.2.0/24",
          "192.168.0.0/16",
          "198.18.0.0/15",
          "198.51.100.0/24",
          "203.0.113.0/24",
          "::1/128",
          "fc00::/7",
          "fe80::/10"
        ],
        "outboundTag": "blocked"
      }
    ]
  },
  "stats": {},
  "api": {
    "services": [
      "StatsService"
    ],
    "tag": "api"
  },
  "policy": {
    "levels": {
      "0": {
        "statsUserDownlink": true,
        "statsUserUplink": true
      }
    },
    "system": {
      "statsInboundUplink": true,
      "statsInboundDownlink": true
    }
  }
}
END

# === TROJAN WS NON-TLS ===
cat > /usr/local/etc/xray/trnone.json << END
{
  "log": {
    "access": "/var/log/xray/access3.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": 10085,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "127.0.0.1"
      },
      "tag": "api"
    },
    {
      "listen": "127.0.0.1",
      "port": 25432,
      "protocol": "trojan",
      "settings": {
        "clients": [
          {
            "password": "${uuid}",
            "level": 0,
            "email": ""
#trnone
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "path": "/trojan",
          "headers": {
            "Host": ""
          }
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "ip": [
          "0.0.0.0/8",
          "10.0.0.0/8",
          "100.64.0.0/10",
          "169.254.0.0/16",
          "172.16.0.0/12",
          "192.0.0.0/24",
          "192.0.2.0/24",
          "192.168.0.0/16",
          "198.18.0.0/15",
          "198.51.100.0/24",
          "203.0.113.0/24",
          "::1/128",
          "fc00::/7",
          "fe80::/10"
        ],
        "outboundTag": "blocked"
      }
    ]
  },
  "stats": {},
  "api": {
    "services": [
      "StatsService"
    ],
    "tag": "api"
  },
  "policy": {
    "levels": {
      "0": {
        "statsUserDownlink": true,
        "statsUserUplink": true
      }
    },
    "system": {
      "statsInboundUplink": true,
      "statsInboundDownlink": true,
      "statsOutboundUplink": true,
      "statsOutboundDownlink": true
    }
  }
}
END

# === TROJAN TCP (untuk fallback dari XTLS) ===
cat > /usr/local/etc/xray/trojan.json << END
{
  "log": {
    "access": "/var/log/xray/access4.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "port": 1310,
      "listen": "127.0.0.1",
      "protocol": "trojan",
      "settings": {
        "clients": [
          {
            "id": "${uuid}",
            "password": "xxxxx"
#tr
          }
        ],
        "fallbacks": [
          {
            "dest": 80
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "none",
        "tcpSettings": {
          "acceptProxyProtocol": true
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "ip": [
          "0.0.0.0/8",
          "10.0.0.0/8",
          "100.64.0.0/10",
          "169.254.0.0/16",
          "172.16.0.0/12",
          "192.0.0.0/24",
          "192.0.2.0/24",
          "192.168.0.0/16",
          "198.18.0.0/15",
          "198.51.100.0/24",
          "203.0.113.0/24",
          "::1/128",
          "fc00::/7",
          "fe80::/10"
        ],
        "outboundTag": "blocked"
      }
    ]
  },
  "stats": {},
  "api": {
    "services": [
      "StatsService"
    ],
    "tag": "api"
  },
  "policy": {
    "levels": {
      "0": {
        "statsUserDownlink": true,
        "statsUserUplink": true
      }
    },
    "system": {
      "statsInboundUplink": true,
      "statsInboundDownlink": true,
      "statsOutboundUplink": true,
      "statsOutboundDownlink": true
    }
  }
}
END

# === TROJAN TCP XTLS ===
cat > /usr/local/etc/xray/xtrojan.json << END
{
  "log": {
    "access": "/var/log/xray/access5.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "inbounds": [
    {
      "port": 443,
      "protocol": "trojan",
      "settings": {
        "clients": [
          {
            "id": "${uuid}",
            "flow": "xtls-rprx-direct",
            "level": 0,
            "email": ""
#trojan-xtls
          }
        ],
        "decryption": "none",
        "fallbacks": [
          {
            "dest": 1310,
            "xver": 1
          },
          {
            "alpn": "h2",
            "dest": 1318,
            "xver": 1
          },
          {
            "path": "/vmess",
            "dest": 1311,
            "xver": 1
          },
          {
            "path": "/vless",
            "dest": 1312,
            "xver": 1
          },
          {
            "path": "/trojan",
            "dest": 1313,
            "xver": 1
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "xtls",
        "xtlsSettings": {
          "minVersion": "1.2",
          "alpn": [
            "http/1.1",
            "h2"
          ],
          "certificates": [
            {
              "certificateFile": "/usr/local/etc/xray/xray.crt",
              "keyFile": "/usr/local/etc/xray/xray.key"
            }
          ]
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom"
    }
  ]
}
END

##############################
#   SYSTEMD SERVICE XRAY     #
##############################

rm -rf /etc/systemd/system/xray.service.d
rm -rf /etc/systemd/system/xray@.service.d

cat > /etc/systemd/system/xray.service << END
[Unit]
Description=XRAY-Websocket Service
Documentation=https://github.com/XTLS/Xray-core
After=network.target nss-lookup.target

[Service]
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /usr/local/etc/xray/config.json
Restart=on-failure
RestartSec=3s
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
END

cat > /etc/systemd/system/xray@.service << END
[Unit]
Description=XRAY-Websocket Service %i
Documentation=https://github.com/XTLS/Xray-core
After=network.target nss-lookup.target

[Service]
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /usr/local/etc/xray/%i.json
Restart=on-failure
RestartSec=3s
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
END

##############################
#      NGINX UNTUK XRAY      #
##############################

cat > /etc/nginx/conf.d/xray.conf <<EOF
server {
    listen 80;
    listen 8080;
    listen 8880;
    listen [::]:80;
    listen [::]:8080;
    listen [::]:8880;
    server_name ${domain};
    ssl_certificate /usr/local/etc/xray/xray.crt;
    ssl_certificate_key /usr/local/etc/xray/xray.key;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
    root /usr/share/nginx/html;

    # VLESS Non-TLS
    location / {
        if (\$http_upgrade != "Upgrade") {
            rewrite /(.*) /vless-ntls break;
        }
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

# Port 81 untuk YAML (ws tls/non-tls dll)
server {
    listen 81;
    listen [::]:81;
    server_name ${domain};
    root /home/vps/public_html;
    index index.html;
}
EOF

##############################
#   ENABLE & RESTART XRAY    #
##############################

echo -e "[ ${orange}SERVICE${NC} ] Restart semua service XRAY & Nginx"
systemctl daemon-reload

# Vmess TLS
echo -e "[ ${green}OK${NC} ] Restarting Vmess WS (TLS)"
systemctl enable xray.service
systemctl restart xray.service

# Vmess Non-TLS
echo -e "[ ${green}OK${NC} ] Restarting Vmess WS (Non-TLS)"
systemctl enable xray@none.service
systemctl restart xray@none.service

# Vless TLS
echo -e "[ ${green}OK${NC} ] Restarting Vless WS (TLS)"
systemctl enable xray@vless.service
systemctl restart xray@vless.service

# Vless Non-TLS
echo -e "[ ${green}OK${NC} ] Restarting Vless WS (Non-TLS)"
systemctl enable xray@vnone.service
systemctl restart xray@vnone.service

# Trojan WS TLS
echo -e "[ ${green}OK${NC} ] Restarting Trojan WS (TLS)"
systemctl enable xray@trojanws.service
systemctl restart xray@trojanws.service

# Trojan WS Non-TLS
echo -e "[ ${green}OK${NC} ] Restarting Trojan WS (Non-TLS)"
systemctl enable xray@trnone.service
systemctl restart xray@trnone.service

# Trojan TCP XTLS
echo -e "[ ${green}OK${NC} ] Restarting Trojan TCP XTLS"
systemctl enable xray@xtrojan.service
systemctl restart xray@xtrojan.service

# Trojan TCP
echo -e "[ ${green}OK${NC} ] Restarting Trojan TCP"
systemctl enable xray@trojan.service
systemctl restart xray@trojan.service

# Nginx
echo -e "[ ${green}OK${NC} ] Restarting Nginx"
systemctl enable nginx
systemctl restart nginx

##############################
#   DOWNLOAD SCRIPT PANEL    #
##############################

cd /usr/bin
echo -e "[ ${green}INFO${NC} ] Mengunduh script manajemen XRAY & VPN..."

# VMESS WS
wget -O add-ws    "https://${Server_URL}/add-ws.sh"    && chmod +x add-ws
wget -O cek-ws    "https://${Server_URL}/cek-ws.sh"    && chmod +x cek-ws
wget -O del-ws    "https://${Server_URL}/del-ws.sh"    && chmod +x del-ws
wget -O renew-ws  "https://${Server_URL}/renew-ws.sh"  && chmod +x renew-ws
wget -O user-ws   "https://${Server_URL}/user-ws.sh"   && chmod +x user-ws
wget -O trial-ws  "https://${Server_URL}/trial-ws.sh"  && chmod +x trial-ws

# VLESS WS
wget -O add-vless    "https://${Server_URL}/add-vless.sh"    && chmod +x add-vless
wget -O cek-vless    "https://${Server_URL}/cek-vless.sh"    && chmod +x cek-vless
wget -O del-vless    "https://${Server_URL}/del-vless.sh"    && chmod +x del-vless
wget -O renew-vless  "https://${Server_URL}/renew-vless.sh"  && chmod +x renew-vless
wget -O user-vless   "https://${Server_URL}/user-vless.sh"   && chmod +x user-vless
wget -O trial-vless  "https://${Server_URL}/trial-vless.sh"  && chmod +x trial-vless

# TROJAN WS
wget -O add-tr    "https://${Server_URL}/add-tr.sh"    && chmod +x add-tr
wget -O cek-tr    "https://${Server_URL}/cek-tr.sh"    && chmod +x cek-tr
wget -O del-tr    "https://${Server_URL}/del-tr.sh"    && chmod +x del-tr
wget -O renew-tr  "https://${Server_URL}/renew-tr.sh"  && chmod +x renew-tr
wget -O user-tr   "https://${Server_URL}/user-tr.sh"   && chmod +x user-tr
wget -O trial-tr  "https://${Server_URL}/trial-tr.sh"  && chmod +x trial-tr

# TROJAN TCP XTLS
wget -O add-xrt    "https://${Server_URL}/add-xrt.sh"    && chmod +x add-xrt
wget -O cek-xrt    "https://${Server_URL}/cek-xrt.sh"    && chmod +x cek-xrt
wget -O del-xrt    "https://${Server_URL}/del-xrt.sh"    && chmod +x del-xrt
wget -O renew-xrt  "https://${Server_URL}/renew-xrt.sh"  && chmod +x renew-xrt
wget -O user-xrt   "https://${Server_URL}/user-xrt.sh"   && chmod +x user-xrt
wget -O trial-xrt  "https://${Server_URL}/trial-xrt.sh"  && chmod +x trial-xrt

# TROJAN TCP
wget -O add-xtr    "https://${Server_URL}/add-xtr.sh"    && chmod +x add-xtr
wget -O cek-xtr    "https://${Server_URL}/cek-xtr.sh"    && chmod +x cek-xtr
wget -O del-xtr    "https://${Server_URL}/del-xtr.sh"    && chmod +x del-xtr
wget -O renew-xtr  "https://${Server_URL}/renew-xtr.sh"  && chmod +x renew-xtr
wget -O user-xtr   "https://${Server_URL}/user-xtr.sh"   && chmod +x user-xtr
wget -O trial-xtr  "https://${Server_URL}/trial-xtr.sh"  && chmod +x trial-xtr

# SSH MANAGEMENT (tanpa trial)
wget -O add-ssh    "https://${Server_URL}/add-ssh.sh"    && chmod +x add-ssh
wget -O del-ssh    "https://${Server_URL}/del-ssh.sh"    && chmod +x del-ssh
wget -O cek-ssh    "https://${Server_URL}/cek-ssh.sh"    && chmod +x cek-ssh
wget -O renew-ssh  "https://${Server_URL}/renew-ssh.sh"  && chmod +x renew-ssh
wget -O user-ssh   "https://${Server_URL}/user-ssh.sh"   && chmod +x user-ssh
wget -O menu-ssh   "https://${Server_URL}/menu-ssh.sh"   && chmod +x menu-ssh

# L2TP MANAGEMENT (tanpa trial)
wget -O add-l2tp    "https://${Server_URL}/add-l2tp.sh"    && chmod +x add-l2tp
wget -O del-l2tp    "https://${Server_URL}/del-l2tp.sh"    && chmod +x del-l2tp
wget -O cek-l2tp    "https://${Server_URL}/cek-l2tp.sh"    && chmod +x cek-l2tp
wget -O renew-l2tp  "https://${Server_URL}/renew-l2tp.sh"  && chmod +x renew-l2tp
wget -O user-l2tp   "https://${Server_URL}/user-l2tp.sh"   && chmod +x user-l2tp
wget -O menu-l2tp   "https://${Server_URL}/menu-l2tp.sh"   && chmod +x menu-l2tp

# MENU XRAY
wget -O menu-ws   "https://${Server_URL}/menu-ws.sh"   && chmod +x menu-ws
wget -O menu-vless "https://${Server_URL}/menu-vless.sh" && chmod +x menu-vless
wget -O menu-tr   "https://${Server_URL}/menu-tr.sh"   && chmod +x menu-tr
wget -O menu-xrt  "https://${Server_URL}/menu-xrt.sh"  && chmod +x menu-xrt
wget -O menu-xtr  "https://${Server_URL}/menu-xtr.sh"  && chmod +x menu-xtr

# SCRIPT TOOL UMUM
wget -O menu     "https://${Server_URL}/menu.sh"        && chmod +x menu
wget -O restart  "https://${Server_URL}/restart.sh"     && chmod +x restart
wget -O status   "https://${Server_URL}/status.sh"      && chmod +x status
wget -O limit    "https://${Server_URL}/limit-speed.sh" && chmod +x limit
wget -O cleaner  "https://${Server_URL}/logcleaner.sh"  && chmod +x cleaner
wget -O media    "https://${Server_URL}/media.sh"       && chmod +x media

echo -e ""
echo -e "[ ${green}INFO${NC} ] Instalasi XRAY selesai."
echo -e "Silakan jalankan perintah: ${green}menu${NC} untuk membuka panel."

# Hapus installer ini (xray.sh), JANGAN sentuh xray2.sh
rm -f /root/xray.sh
exit 0

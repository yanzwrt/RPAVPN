#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Lite WS+SNI V1.0
# Author  : Rakha-VPN (Mod)
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

# Ambil IP (tidak terlalu penting untuk xray, tapi disimpan jika perlu)
MYIP=$(curl -sS ifconfig.me)

red()    { echo -e "\\033[31;1m${*}\\033[0m"; }
green()  { echo -e "\\033[32;1m${*}\\033[0m"; }
yellow() { echo -e "\\033[33;1m${*}\\033[0m"; }
purple() { echo -e "\\033[35;1m${*}\\033[0m"; }

echo ""
if [ ! -f "/root/domain" ]; then
    red "File /root/domain tidak ditemukan! Pastikan domain sudah di-set."
    exit 1
fi

domain=$(cat /root/domain)
green "[INFO] Menggunakan domain: ${domain}"
sleep 1

echo -e "[ ${green}INFO${NC} ] Memulai instalasi XRAY Core (Lite, WS+SNI) ..."

# --- Update & paket dasar (ringan, tanpa SSH/L2TP) ---
apt update -y
apt upgrade -y
apt install -y socat python3 curl wget sed nano zip pwgen openssl netcat cron \
               xz-utils apt-transport-https gnupg gnupg2 gnupg1 dnsutils lsb-release \
               bash-completion ntpdate

# Sinkronisasi waktu (penting untuk TLS)
ntpdate pool.ntp.org
apt -y install chrony
timedatectl set-ntp true
systemctl enable chronyd >/dev/null 2>&1 || true
systemctl restart chronyd >/dev/null 2>&1 || true
systemctl enable chrony >/dev/null 2>&1 || true
systemctl restart chrony >/dev/null 2>&1 || true
timedatectl set-timezone Asia/Jakarta
date

# Folder log & config XRAY
mkdir -p /var/log/xray
chmod 755 /var/log/xray

mkdir -p /usr/local/etc/xray

# --- Install Xray Core binary (build dari repo kamu) ---
wget -O /usr/local/bin/xray "https://${Server_URL}/xray.linux.64bit"
chmod +x /usr/local/bin/xray

# --- Generate sertifikat menggunakan acme.sh ---
mkdir -p /root/.acme.sh
curl -s "https://${Server_URL}/acme.sh" -o /root/.acme.sh/acme.sh
chmod +x /root/.acme.sh/acme.sh
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue -d "${domain}" --standalone -k ec-256
/root/.acme.sh/acme.sh --installcert -d "${domain}" \
    --fullchainpath /usr/local/etc/xray/xray.crt \
    --keypath /usr/local/etc/xray/xray.key --ecc

# --- Web root untuk file YAML dsb ---
mkdir -p /home/vps/public_html

# UUID default (akan diganti oleh script add-* utk tiap client)
uuid=$(cat /proc/sys/kernel/random/uuid)

# =======================
#   KONFIG XRAY INTI
# =======================

# VMESS WS (TLS via XTLS fallback) -> /usr/local/etc/xray/config.json
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
    "services": [ "StatsService" ],
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

# VMESS WS NON-TLS -> /usr/local/etc/xray/none.json
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
        "sockopt": {
          "mark": 0,
          "tcpFastOpen": true
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [ "http", "tls" ]
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
    "services": [ "StatsService" ],
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

# VLESS WS TLS (via XTLS path fallback) -> /usr/local/etc/xray/vless.json
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
    "services": [ "StatsService" ],
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

# VLESS WS NON-TLS -> /usr/local/etc/xray/vnone.json
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
        "sockopt": {
          "mark": 0,
          "tcpFastOpen": true
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [ "http", "tls" ]
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
    "services": [ "StatsService" ],
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

# TROJAN WS TLS -> /usr/local/etc/xray/trojanws.json
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
    "rules": []
  },
  "stats": {},
  "api": {
    "services": [ "StatsService" ],
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

# TROJAN WS NON-TLS -> /usr/local/etc/xray/trnone.json
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
    "rules": []
  },
  "stats": {},
  "api": {
    "services": [ "StatsService" ],
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

# TROJAN TCP (TLS dari luar / xtls fallback) -> /usr/local/etc/xray/trojan.json
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
    "rules": []
  },
  "stats": {},
  "api": {
    "services": [ "StatsService" ],
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

# TROJAN TCP XTLS (front-end 443, fallback WS/TCP) -> /usr/local/etc/xray/xtrojan.json
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
        "destOverride": [ "http", "tls" ]
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

# ==========================
#   SYSTEMD SERVICE XRAY
# ==========================
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

# ==========================
#   NGINX REVERSE PROXY
# ==========================
# Pastikan nginx sudah terinstall oleh setup.sh sebelumnya
cat > /etc/nginx/conf.d/xray.conf << EOF
server {
    listen 80;
    listen [::]:80;
    listen 8080;
    listen [::]:8080;
    listen 8880;
    listen [::]:8880;
    server_name 127.0.0.1 localhost;
    ssl_certificate /usr/local/etc/xray/xray.crt;
    ssl_certificate_key /usr/local/etc/xray/xray.key;
    ssl_ciphers EECDH+CHACHA20:EECDH+ECDSA+AES128:EECDH+aRSA+AES128:RSA+AES128:EECDH+ECDSA+AES256:EECDH+aRSA+AES256:RSA+AES256:EECDH+ECDSA+3DES:EECDH+aRSA+3DES:RSA+3DES:!MD5;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
    root /usr/share/nginx/html;
}
EOF

# Default: semua request / diarahkan ke VLESS non-tls (bisa dipakai untuk bug host/SNI)
sed -i '$ ilocation /' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ i    if ($http_upgrade != "Upgrade") {' /etc/nginx/conf.d/xray.conf
sed -i '$ i        rewrite /(.*) /vless-ntls break;' /etc/nginx/conf.d/xray.conf
sed -i '$ i    }' /etc/nginx/conf.d/xray.conf
sed -i '$ i    proxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ i    proxy_pass http://127.0.0.1:14016;' /etc/nginx/conf.d/xray.conf
sed -i '$ i    proxy_http_version 1.1;' /etc/nginx/conf.d/xray.conf
sed -i '$ i    proxy_set_header X-Real-IP $remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ i    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ i    proxy_set_header Upgrade $http_upgrade;' /etc/nginx/conf.d/xray.conf
sed -i '$ i    proxy_set_header Connection "upgrade";' /etc/nginx/conf.d/xray.conf
sed -i '$ i    proxy_set_header Host $http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

# Lokasi khusus VMESS NON-TLS
sed -i '$ ilocation = /vmess-ntls' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ i    proxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ i    proxy_pass http://127.0.0.1:23456;' /etc/nginx/conf.d/xray.conf
sed -i '$ i    proxy_http_version 1.1;' /etc/nginx/conf.d/xray.conf
sed -i '$ i    proxy_set_header X-Real-IP $remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ i    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ i    proxy_set_header Upgrade $http_upgrade;' /etc/nginx/conf.d/xray.conf
sed -i '$ i    proxy_set_header Connection "upgrade";' /etc/nginx/conf.d/xray.conf
sed -i '$ i    proxy_set_header Host $http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

# Lokasi khusus TROJAN NON-TLS
sed -i '$ ilocation = /trojan-ntls' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ i    proxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ i    proxy_pass http://127.0.0.1:25432;' /etc/nginx/conf.d/xray.conf
sed -i '$ i    proxy_http_version 1.1;' /etc/nginx/conf.d/xray.conf
sed -i '$ i    proxy_set_header X-Real-IP $remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ i    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ i    proxy_set_header Upgrade $http_upgrade;' /etc/nginx/conf.d/xray.conf
sed -i '$ i    proxy_set_header Connection "upgrade";' /etc/nginx/conf.d/xray.conf
sed -i '$ i    proxy_set_header Host $http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

# ===================
#   RESTART SERVICE
# ===================
echo -e "[ ${orange}SERVICE${NC} ] Restart semua service terkait ..."
systemctl daemon-reload

# VMESS TLS
systemctl enable xray.service
systemctl restart xray.service

# VMESS NON-TLS
systemctl enable xray@none.service
systemctl restart xray@none.service

# VLESS TLS
systemctl enable xray@vless.service
systemctl restart xray@vless.service

# VLESS NON-TLS
systemctl enable xray@vnone.service
systemctl restart xray@vnone.service

# TROJAN WS TLS
systemctl enable xray@trojanws.service
systemctl restart xray@trojanws.service

# TROJAN WS NON-TLS
systemctl enable xray@trnone.service
systemctl restart xray@trnone.service

# TROJAN TCP XTLS
systemctl enable xray@xtrojan.service
systemctl restart xray@xtrojan.service

# TROJAN TCP
systemctl enable xray@trojan.service
systemctl restart xray@trojan.service

# NGINX
systemctl enable nginx
systemctl restart nginx

# ==========================
#   DOWNLOAD SCRIPT XRAY
#   (tanpa SSH & L2TP)
# ==========================
cd /usr/bin
echo -e "[ ${green}INFO${NC} ] Mengunduh file manajemen XRAY ..."

# VMESS WS
wget -O add-ws    "https://${Server_URL}/add-ws.sh"    && chmod +x add-ws
wget -O cek-ws    "https://${Server_URL}/cek-ws.sh"    && chmod +x cek-ws
wget -O del-ws    "https://${Server_URL}/del-ws.sh"    && chmod +x del-ws
wget -O renew-ws  "https://${Server_URL}/renew-ws.sh"  && chmod +x renew-ws
wget -O user-ws   "https://${Server_URL}/user-ws.sh"   && chmod +x user-ws
wget -O trial-ws  "https://${Server_URL}/trial-ws.sh"  && chmod +x trial-ws

# VLESS WS
wget -O add-vless   "https://${Server_URL}/add-vless.sh"   && chmod +x add-vless
wget -O cek-vless   "https://${Server_URL}/cek-vless.sh"   && chmod +x cek-vless
wget -O del-vless   "https://${Server_URL}/del-vless.sh"   && chmod +x del-vless
wget -O renew-vless "https://${Server_URL}/renew-vless.sh" && chmod +x renew-vless
wget -O user-vless  "https://${Server_URL}/user-vless.sh"  && chmod +x user-vless
wget -O trial-vless "https://${Server_URL}/trial-vless.sh" && chmod +x trial-vless

# TROJAN WS
wget -O add-tr    "https://${Server_URL}/add-tr.sh"    && chmod +x add-tr
wget -O cek-tr    "https://${Server_URL}/cek-tr.sh"    && chmod +x cek-tr
wget -O del-tr    "https://${Server_URL}/del-tr.sh"    && chmod +x del-tr
wget -O renew-tr  "https://${Server_URL}/renew-tr.sh"  && chmod +x renew-tr
wget -O user-tr   "https://${Server_URL}/user-tr.sh"   && chmod +x user-tr
wget -O trial-tr  "https://${Server_URL}/trial-tr.sh"  && chmod +x trial-tr

# TROJAN TCP XTLS (xrt)
wget -O add-xrt    "https://${Server_URL}/add-xrt.sh"    && chmod +x add-xrt
wget -O cek-xrt    "https://${Server_URL}/cek-xrt.sh"    && chmod +x cek-xrt
wget -O del-xrt    "https://${Server_URL}/del-xrt.sh"    && chmod +x del-xrt
wget -O renew-xrt  "https://${Server_URL}/renew-xrt.sh"  && chmod +x renew-xrt
wget -O user-xrt   "https://${Server_URL}/user-xrt.sh"   && chmod +x user-xrt
wget -O trial-xrt  "https://${Server_URL}/trial-xrt.sh"  && chmod +x trial-xrt

# TROJAN TCP (xtr)
wget -O add-xtr    "https://${Server_URL}/add-xtr.sh"    && chmod +x add-xtr
wget -O cek-xtr    "https://${Server_URL}/cek-xtr.sh"    && chmod +x cek-xtr
wget -O del-xtr    "https://${Server_URL}/del-xtr.sh"    && chmod +x del-xtr
wget -O renew-xtr  "https://${Server_URL}/renew-xtr.sh"  && chmod +x renew-xtr
wget -O user-xtr   "https://${Server_URL}/user-xtr.sh"   && chmod +x user-xtr
wget -O trial-xtr  "https://${Server_URL}/trial-xtr.sh"  && chmod +x trial-xtr

echo -e "[ ${green}DONE${NC} ] Instalasi XRAY Lite (WS + SNI) selesai."
echo -e "Silakan gunakan menu utama (menu) untuk mengelola akun."

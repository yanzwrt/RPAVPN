#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edisi   : Stable Edition V1.0
# Pembuat : Rakha-VPN
# (C) Hak Cipta 2025
# =========================================

red='\e[1;31m'
green='\e[0;32m'
purple='\e[0;35m'
orange='\e[0;33m'
NC='\e[0m'

clear
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e " ${green}     🖥️  STATUS LAYANAN SERVER VPS  🖥️        ${NC}"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Fungsi cek service
cek_service() {
  local svc="$1"
  local label="$2"

  status="$(systemctl show "${svc}.service" --no-page 2>/dev/null)"
  status_text=$(echo "${status}" | grep 'ActiveState=' | cut -f2 -d=)

  if [ "${status_text}" == "active" ]; then
    echo -e " ${purple}♦${NC} ${label} : ${green}✅ Aktif (Berjalan)${NC}"
  else
    echo -e " ${purple}♦${NC} ${label} : ${red}❌ Tidak Aktif (Error)${NC}"
  fi
}

# ====== Layanan Sistem Dasar ======
cek_service cron          "Cron Service               "
cek_service nginx         "Nginx Web Server           "
cek_service fail2ban      "Fail2Ban Security          "

# ====== SSH & Dropbear ======
# Sesuaikan nama service kalau berbeda di OS kamu
cek_service ssh           "OpenSSH (SSH)              "
cek_service dropbear      "Dropbear SSH               "

# ====== L2TP / IPsec ======
# strongSwan di-install dengan nama service "strongswan" di l2tp.sh
cek_service strongswan    "IPsec (strongSwan)         "
cek_service xl2tpd        "L2TP Server (xl2tpd)       "

# ====== XRAY Core ======
cek_service xray          "XRAY Vmess TLS             "
cek_service xray@none     "XRAY Vmess Non TLS         "
cek_service xray@vless    "XRAY Vless TLS             "
cek_service xray@vnone    "XRAY Vless Non TLS         "
cek_service xray@trojanws "XRAY Trojan TLS (WS)       "
cek_service xray@trnone   "XRAY Trojan Non TLS        "
cek_service xray@xtrojan  "XRAY Trojan TCP XTLS       "
cek_service xray@trojan   "XRAY Trojan TCP TLS        "

echo ""
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""


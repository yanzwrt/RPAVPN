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

status="$(systemctl show cron.service --no-page)"
status_text=$(echo "${status}" | grep 'ActiveState=' | cut -f2 -d=)
if [ "${status_text}" == "active" ]; then
  echo -e " ${purple}♦${NC} Cron Service               : ${green}✅ Aktif (Berjalan)${NC}"
else
  echo -e " ${purple}♦${NC} Cron Service               : ${red}❌ Tidak Aktif (Error)${NC}"
fi

status="$(systemctl show nginx.service --no-page)"
status_text=$(echo "${status}" | grep 'ActiveState=' | cut -f2 -d=)
if [ "${status_text}" == "active" ]; then
  echo -e " ${purple}♦${NC} Nginx Web Server           : ${green}✅ Aktif (Berjalan)${NC}"
else
  echo -e " ${purple}♦${NC} Nginx Web Server           : ${red}❌ Tidak Aktif (Error)${NC}"
fi

status="$(systemctl show fail2ban.service --no-page)"
status_text=$(echo "${status}" | grep 'ActiveState=' | cut -f2 -d=)
if [ "${status_text}" == "active" ]; then
  echo -e " ${purple}♦${NC} Fail2Ban Security          : ${green}✅ Aktif (Berjalan)${NC}"
else
  echo -e " ${purple}♦${NC} Fail2Ban Security          : ${red}❌ Tidak Aktif (Error)${NC}"
fi

status="$(systemctl show xray.service --no-page)"
status_text=$(echo "${status}" | grep 'ActiveState=' | cut -f2 -d=)
if [ "${status_text}" == "active" ]; then
  echo -e " ${purple}♦${NC} XRAY Vmess TLS             : ${green}✅ Aktif (Berjalan)${NC}"
else
  echo -e " ${purple}♦${NC} XRAY Vmess TLS             : ${red}❌ Tidak Aktif (Error)${NC}"
fi

status="$(systemctl show xray@vless.service --no-page)"
status_text=$(echo "${status}" | grep 'ActiveState=' | cut -f2 -d=)
if [ "${status_text}" == "active" ]; then
  echo -e " ${purple}♦${NC} XRAY Vless TLS             : ${green}✅ Aktif (Berjalan)${NC}"
else
  echo -e " ${purple}♦${NC} XRAY Vless TLS             : ${red}❌ Tidak Aktif (Error)${NC}"
fi

status="$(systemctl show xray@trojanws.service --no-page)"
status_text=$(echo "${status}" | grep 'ActiveState=' | cut -f2 -d=)
if [ "${status_text}" == "active" ]; then
  echo -e " ${purple}♦${NC} XRAY Trojan TLS (WS)       : ${green}✅ Aktif (Berjalan)${NC}"
else
  echo -e " ${purple}♦${NC} XRAY Trojan TLS (WS)       : ${red}❌ Tidak Aktif (Error)${NC}"
fi

status="$(systemctl show xray@none.service --no-page)"
status_text=$(echo "${status}" | grep 'ActiveState=' | cut -f2 -d=)
if [ "${status_text}" == "active" ]; then
  echo -e " ${purple}♦${NC} XRAY Vmess Non TLS         : ${green}✅ Aktif (Berjalan)${NC}"
else
  echo -e " ${purple}♦${NC} XRAY Vmess Non TLS         : ${red}❌ Tidak Aktif (Error)${NC}"
fi

status="$(systemctl show xray@vnone.service --no-page)"
status_text=$(echo "${status}" | grep 'ActiveState=' | cut -f2 -d=)
if [ "${status_text}" == "active" ]; then
  echo -e " ${purple}♦${NC} XRAY Vless Non TLS         : ${green}✅ Aktif (Berjalan)${NC}"
else
  echo -e " ${purple}♦${NC} XRAY Vless Non TLS         : ${red}❌ Tidak Aktif (Error)${NC}"
fi

status="$(systemctl show xray@trnone.service --no-page)"
status_text=$(echo "${status}" | grep 'ActiveState=' | cut -f2 -d=)
if [ "${status_text}" == "active" ]; then
  echo -e " ${purple}♦${NC} XRAY Trojan Non TLS        : ${green}✅ Aktif (Berjalan)${NC}"
else
  echo -e " ${purple}♦${NC} XRAY Trojan Non TLS        : ${red}❌ Tidak Aktif (Error)${NC}"
fi

status="$(systemctl show xray@xtrojan.service --no-page)"
status_text=$(echo "${status}" | grep 'ActiveState=' | cut -f2 -d=)
if [ "${status_text}" == "active" ]; then
  echo -e " ${purple}♦${NC} XRAY Trojan TCP XTLS       : ${green}✅ Aktif (Berjalan)${NC}"
else
  echo -e " ${purple}♦${NC} XRAY Trojan TCP XTLS       : ${red}❌ Tidak Aktif (Error)${NC}"
fi

status="$(systemctl show xray@trojan.service --no-page)"
status_text=$(echo "${status}" | grep 'ActiveState=' | cut -f2 -d=)
if [ "${status_text}" == "active" ]; then
  echo -e " ${purple}♦${NC} XRAY Trojan TCP TLS        : ${green}✅ Aktif (Berjalan)${NC}"
else
  echo -e " ${purple}♦${NC} XRAY Trojan TCP TLS        : ${red}❌ Tidak Aktif (Error)${NC}"
fi

echo ""
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition V1.1
# Author  : RakhaVPN
# (C) Copyright 2025
# =========================================

red='\e[1;31m'
green='\e[0;32m'
yellow='\e[1;33m'
NC='\e[0m'

green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red()   { echo -e "\\033[31;1m${*}\\033[0m";  }

LOG_TROJAN_WS="/var/log/xray/access3.log"
CONF_TROJAN_WS="/usr/local/etc/xray/trojanws.json"

clear

# Cek apakah file config ada
if [[ ! -f "$CONF_TROJAN_WS" ]]; then
  echo -e "${red}Konfigurasi $CONF_TROJAN_WS tidak ditemukan!${NC}"
  read -n1 -r -p "Tekan [ Enter ] untuk kembali ke menu..."
  menu
  exit 1
fi

NUMBER_OF_CLIENTS=$(grep -c -E "^### " "$CONF_TROJAN_WS")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\\E[0;47;30m     PENGGUNA LOGIN TROJAN WS     \E[0m"
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo ""
    echo "Belum ada user yang terdaftar!"
    echo ""
    read -n1 -r -p "Tekan [ Enter ] kembali ke menu..."
    menu
    exit 0
fi

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\\E[0;47;30m     PENGGUNA LOGIN TROJAN WS     \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo " Daftar user trojan WS:"
grep -E "^### " "$CONF_TROJAN_WS" | cut -d ' ' -f 2-3 | nl -s ') '
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# Pilih user
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
    read -rp "Pilih user [1-${NUMBER_OF_CLIENTS}] : " CLIENT_NUMBER
done

user=$(grep -E "^### " "$CONF_TROJAN_WS" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "$CONF_TROJAN_WS" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)

clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\\E[0;47;30m   DETAIL LOGIN TROJAN WS USER    \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "➤ Username : ${green}${user}${NC}"
echo -e "➤ Expired  : ${yellow}${exp}${NC}"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# Cek log hanya kalau file log ada
if [[ -f "$LOG_TROJAN_WS" ]]; then
    # Ambil 5000 baris terakhir saja biar ringan
    LOG_DATA=$(tail -n 5000 "$LOG_TROJAN_WS" 2>/dev/null | grep -a "$user" 2>/dev/null)

    if [[ -z "$LOG_DATA" ]]; then
        echo -e "Tidak ada aktivitas login yang tercatat di log."
    else
        # Ambil IP unik dari log (kolom ke-3 biasanya IP, tergantung format log)
        echo -e "IP yang pernah / sedang login:"
        echo "$LOG_DATA" | awk '{print $3}' | sort | uniq | nl -s '. '
    fi
else
    echo -e "File log ${LOG_TROJAN_WS} tidak ditemukan."
fi

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo ""
read -n1 -r -p "Press [ Enter ] kembali ke menu . . . "
menu

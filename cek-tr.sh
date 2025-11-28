#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition V1.1
# Author  : RakhaVPN
# (C) Copyright 2025
# =========================================

red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'

LOG_FILE="/var/log/xray/access3.log"
CONF_FILE="/usr/local/etc/xray/trojanws.json"

clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\\E[0;47;30m     Pengguna Login XRAY Trojan WS     \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# Cek file log
if [[ ! -f "$LOG_FILE" ]]; then
  echo ""
  echo "Log tidak ditemukan: $LOG_FILE"
  echo "Belum ada aktivitas koneksi atau XRAY belum menulis log."
  echo ""
  read -n1 -s -r -p "Press [ Enter ] kembali ke menu . . . "
  menu
  exit 0
fi

# Ambil list user dari trojanws.json
mapfile -t users < <(grep -E "^### " "$CONF_FILE" 2>/dev/null | awk '{print $2}')

if [[ ${#users[@]} -eq 0 ]]; then
  echo ""
  echo "Belum ada user Trojan WS yang terdaftar."
  echo ""
  read -n1 -s -r -p "Press [ Enter ] kembali ke menu . . . "
  menu
  exit 0
fi

ada_login=false

echo ""

# Proses log lewat `strings` supaya tidak dianggap biner
# lalu baru di-grep per user
for user in "${users[@]}"; do
  ip_list=$(strings -a "$LOG_FILE" 2>/dev/null \
    | grep -F " ${user}" 2>/dev/null \
    | awk '{print $3}' \
    | cut -d: -f1 \
    | sort -u)

  if [[ -n "$ip_list" ]]; then
    ada_login=true
    echo -e "${green}User : ${user}${NC}"
    echo "$ip_list" | nl -s '. '
    echo ""
  fi
done

if [[ "$ada_login" = false ]]; then
  echo "Tidak ada user Trojan WS yang sedang aktif / tercatat di log saat ini."
  echo ""
fi

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
read -n1 -s -r -p "Press [ Enter ] kembali ke menu . . . "
menu

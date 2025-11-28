#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition V1.1
# Author  : RakhaVPN
# (C) Copyright 2025
# =========================================

red='\e[1;31m'
green='\e[0;32m'
yellow='\e[0;33m'
NC='\e[0m'

SYSLOG="/var/log/syslog"

clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\\E[0;47;30m     Pengguna Login L2TP/IPSEC    \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

if [[ ! -f "$SYSLOG" ]]; then
  echo -e " ${red}Log tidak ditemukan: $SYSLOG${NC}"
  echo ""
  read -n1 -s -r -p "Press [ Enter ] kembali ke menu . . . "
  menu
  exit 0
fi

# Cari baris pppd yang berhubungan dengan autentikasi sukses
mapfile -t lines < <(grep -a "pppd" "$SYSLOG" 2>/dev/null \
  | grep -a -E "PAP authentication succeeded|peer name" 2>/dev/null)

if [[ ${#lines[@]} -eq 0 ]]; then
  echo -e " ${yellow}Belum ada login L2TP/IPsec yang tercatat.${NC}"
  echo ""
  read -n1 -s -r -p "Press [ Enter ] kembali ke menu . . . "
  menu
  exit 0
fi

echo -e " Daftar login L2TP/IPsec (user / peer):"
echo -e "-----------------------------------------------"

# Ambil user dari "peer name 'user'" atau serupa
grep -a "pppd" "$SYSLOG" 2>/dev/null \
  | grep -a "peer name" 2>/dev/null \
  | awk -F"'" '{print $2}' \
  | sort | uniq -c | sort -nr > /tmp/.l2tp_parsed_$$

if [[ ! -s /tmp/.l2tp_parsed_$$ ]]; then
  echo -e " ${yellow}Tidak dapat mem-parsing user L2TP dari log.${NC}"
else
  printf " %-3s %-20s %-8s\n" "No" "User (peer)" "Login"
  echo -e "-----------------------------------------------"
  no=1
  while read -r line; do
    count=$(echo "$line" | awk '{print $1}')
    user=$(echo "$line" | awk '{print $2}')
    printf " %-3s %-20s %-8s\n" "$no" "$user" "$count"
    ((no++))
  done < /tmp/.l2tp_parsed_$$
fi

rm -f /tmp/.l2tp_parsed_$$ 2>/dev/null

echo ""
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e " ${green}Selesai menampilkan login L2TP/IPsec.${NC}"
echo ""
read -n1 -s -r -p "Press [ Enter ] kembali ke menu . . . "
menu

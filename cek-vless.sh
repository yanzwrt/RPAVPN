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

LOG_FILE="/var/log/xray/access2.log"

clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\\E[0;47;30m   Pengguna Login XRAY VLESS WS   \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

if [[ ! -f "$LOG_FILE" ]]; then
  echo -e " ${red}Log tidak ditemukan: $LOG_FILE${NC}"
  echo ""
  read -n1 -s -r -p "Press [ Enter ] kembali ke menu . . . "
  menu
  exit 0
fi

mapfile -t online_users < <(grep -a "email:" "$LOG_FILE" 2>/dev/null \
  | awk -F'email: ' 'NF>1 {print $2}' \
  | awk '{print $1}' \
  | sort -u)

if [[ ${#online_users[@]} -eq 0 ]]; then
  echo -e " ${yellow}Belum ada user VLESS WS yang tercatat login.${NC}"
  echo ""
  read -n1 -s -r -p "Press [ Enter ] kembali ke menu . . . "
  menu
  exit 0
fi

printf " %-3s %-15s %-8s %-40s\n" "No" "User" "Login" "IP Terakhir"
echo -e "-----------------------------------------------"

no=1
for user in "${online_users[@]}"; do
  count=$(grep -a "email: ${user}" "$LOG_FILE" 2>/dev/null | wc -l)
  last_ip=$(grep -a "email: ${user}" "$LOG_FILE" 2>/dev/null \
    | awk '{print $3}' \
    | cut -d: -f1 \
    | tail -n1)
  [[ -z "$last_ip" ]] && last_ip="-"

  printf " %-3s %-15s %-8s %-40s\n" "$no" "$user" "$count" "$last_ip"
  ((no++))
done

echo ""
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e " ${green}Selesai menampilkan login XRAY VLESS WS.${NC}"
echo ""
read -n1 -s -r -p "Press [ Enter ] kembali ke menu . . . "
menu


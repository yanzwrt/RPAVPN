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

AUTH_LOG="/var/log/auth.log"

clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\\E[0;47;30m   Pengguna Login SSH & WS-SSH    \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

if [[ ! -f "$AUTH_LOG" ]]; then
  echo -e " ${red}Log tidak ditemukan: $AUTH_LOG${NC}"
  echo ""
  read -n1 -s -r -p "Press [ Enter ] kembali ke menu . . . "
  menu
  exit 0
fi

# Ambil semua baris "Accepted" (password/pubkey)
mapfile -t lines < <(grep -a "Accepted" "$AUTH_LOG" 2>/dev/null)

if [[ ${#lines[@]} -eq 0 ]]; then
  echo -e " ${yellow}Belum ada login SSH yang tercatat.${NC}"
  echo ""
  read -n1 -s -r -p "Press [ Enter ] kembali ke menu . . . "
  menu
  exit 0
fi

# User dan IP dari log
# format umum: ... Accepted password for <user> from <ip> port ...
echo -e " Daftar login SSH terakhir (user & IP):"
echo -e "-----------------------------------------------"
echo "${lines[@]}" \
  | tr ' ' '\n' > /tmp/.sshlog_tmp_$$

# Cara lebih mudah: pakai awk langsung
grep -a "Accepted" "$AUTH_LOG" 2>/dev/null \
  | awk '{
      # cari kata "for" & "from"
      for(i=1;i<=NF;i++){
        if($i=="for"){user=$(i+1)}
        if($i=="from"){ip=$(i+1)}
      }
      if(user!="" && ip!=""){
        print user" "ip
      }
    }' \
  | sort | uniq -c | sort -nr > /tmp/.sshlog_parsed_$$

if [[ ! -s /tmp/.sshlog_parsed_$$ ]]; then
  echo -e " ${yellow}Tidak dapat mem-parsing login SSH dari log.${NC}"
else
  printf " %-3s %-15s %-15s %-8s\n" "No" "User" "IP" "Login"
  echo -e "-----------------------------------------------"
  no=1
  while read -r line; do
    count=$(echo "$line" | awk '{print $1}')
    user=$(echo "$line" | awk '{print $2}')
    ip=$(echo "$line" | awk '{print $3}')
    printf " %-3s %-15s %-15s %-8s\n" "$no" "$user" "$ip" "$count"
    ((no++))
  done < /tmp/.sshlog_parsed_$$
fi

rm -f /tmp/.sshlog_tmp_$$ /tmp/.sshlog_parsed_$$ 2>/dev/null

echo ""
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e " ${green}Selesai menampilkan login SSH & Websocket.${NC}"
echo ""
read -n1 -s -r -p "Press [ Enter ] kembali ke menu . . . "
menu

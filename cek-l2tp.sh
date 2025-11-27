#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition V1.0
# Author  : RakhaVPN (mod RPAVPN)
# (C) Copyright 2025
# =========================================

clear

red='\e[1;31m'
green='\e[0;32m'
orange='\e[1;33m'
CYAN='\e[0;36m'
NC='\e[0m'

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e " \E[0;47;30m        L2TP/IPSec User Login       \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# Cek file log
LOG_SYS="/var/log/syslog"
if [[ ! -f "$LOG_SYS" ]]; then
  echo -e "${red}Log $LOG_SYS tidak ditemukan.${NC}"
  echo ""
  read -p "$( echo -e "Press ${orange}[ ${NC}${green}Enter${NC} ${CYAN}]${NC} kembali ke menu . . .") "
  menu
fi

# Ambil list user L2TP dari chap-secrets (baris yang diawali ### user exp)
if [[ ! -f /etc/ppp/chap-secrets ]]; then
  echo -e "${red}/etc/ppp/chap-secrets tidak ditemukan.${NC}"
  echo ""
  read -p "$( echo -e "Press ${orange}[ ${NC}${green}Enter${NC} ${CYAN}]${NC} kembali ke menu . . .") "
  menu
fi

data=( $(grep '^###' /etc/ppp/chap-secrets 2>/dev/null | awk '{print $2}' | sort -u) )

if [[ ${#data[@]} -eq 0 ]]; then
  echo -e "${red}Belum ada user L2TP yang terdaftar lewat script.${NC}"
  echo ""
  read -p "$( echo -e "Press ${orange}[ ${NC}${green}Enter${NC} ${CYAN}]${NC} kembali ke menu . . .") "
  menu
fi

tmpfile="/tmp/l2tp_online.txt"
> "$tmpfile"

# Ambil 500 baris terakhir yang terkait pppd (L2TP)
mapfile -t pppd_logs < <(grep "pppd" "$LOG_SYS" | tail -n 500)

for akun in "${data[@]}"; do
  [[ -z "$akun" ]] && continue

  # Cari baris dengan user 'username'
  user_lines=( $(printf "%s\n" "${pppd_logs[@]}" | grep "user '$akun'" || true) )

  if [[ ${#user_lines[@]} -eq 0 ]]; then
    continue
  fi

  # Ambil PID dari baris pppd
  pids=( $(printf "%s\n" "${user_lines[@]}" | awk -F'[][]' '{print $2}' | sort -u) )

  for pid in "${pids[@]}"; do
    # Cari baris remote IP untuk PID tersebut
    ip_line=$(printf "%s\n" "${pppd_logs[@]}" | grep "pppd\[$pid\]" | grep "remote IP address" | tail -n 1)
    if [[ -n "$ip_line" ]]; then
      rip=$(echo "$ip_line" | awk '{print $NF}')
      echo "$akun $rip" >> "$tmpfile"
    else
      # Kalau nggak ketemu remote IP, tetap catat user tanpa IP
      echo "$akun -" >> "$tmpfile"
    fi
  done
done

if [[ ! -s "$tmpfile" ]]; then
  echo -e "${red}Belum ada aktivitas login L2TP yang tercatat di log (500 baris terakhir).${NC}"
  echo ""
  rm -f "$tmpfile"
  read -p "$( echo -e "Press ${orange}[ ${NC}${green}Enter${NC} ${CYAN}]${NC} kembali ke menu . . .") "
  menu
fi

# Tampilkan per user
for akun in "${data[@]}"; do
  iplist=( $(awk -v usr="$akun" '$1==usr {print $2}' "$tmpfile" | sort -u) )
  if [[ ${#iplist[@]} -gt 0 ]]; then
    echo "User : $akun"
    for ip in "${iplist[@]}"; do
      [[ "$ip" == "-" ]] && ip="(IP tidak terdeteksi dari log)"
      echo "$ip"
    done | nl -ba
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
  fi
done

rm -f "$tmpfile"

echo ""
read -p "$( echo -e "Press ${orange}[ ${NC}${green}Enter${NC} ${CYAN}]${NC} kembali ke menu . . .") "
menu

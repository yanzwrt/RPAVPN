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
echo -e " \E[0;47;30m    Pengguna Login SSH (OpenSSH/Dropbear)   \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# Ambil daftar user SSH VPN (dibuat oleh add-ssh: /bin/false, UID >= 1000)
vpn_users=( $(awk -F: '$3>=1000 && $7=="/bin/false" {print $1}' /etc/passwd) )

if [[ ${#vpn_users[@]} -eq 0 ]]; then
  echo -e "${red}Belum ada user SSH VPN (akun /bin/false).${NC}"
  echo ""
  read -p "$( echo -e "Press ${orange}[ ${NC}${green}Enter${NC} ${CYAN}]${NC} kembali ke menu . . .") "
  menu
fi

# Pakai netstat untuk ambil koneksi sshd & dropbear yang ESTABLISHED
mapfile -t ssh_lines < <(netstat -tnpa 2>/dev/null | grep ESTABLISHED | grep -E 'sshd|dropbear')

if [[ ${#ssh_lines[@]} -eq 0 ]]; then
  echo -e "${red}Tidak ada koneksi SSH/Dropbear yang aktif saat ini.${NC}"
  echo ""
  read -p "$( echo -e "Press ${orange}[ ${NC}${green}Enter${NC} ${CYAN}]${NC} kembali ke menu . . .") "
  menu
fi

# Kumpulan data: user -> list IP
tmpfile="/tmp/online_ssh.txt"
> "$tmpfile"

for line in "${ssh_lines[@]}"; do
  # Kolom 5 = foreign address, kolom 7 = pid/program
  ip=$(echo "$line" | awk '{print $5}' | cut -d: -f1)
  pid=$(echo "$line" | awk '{print $7}' | cut -d/ -f1)

  # Ambil user dari PID
  login_user=$(ps -p "$pid" -o user= 2>/dev/null | xargs)

  # Pastikan user ini adalah salah satu VPN user
  for u in "${vpn_users[@]}"; do
    if [[ "$login_user" == "$u" ]]; then
      echo "$login_user $ip" >> "$tmpfile"
    fi
  done
done

if [[ ! -s "$tmpfile" ]]; then
  echo -e "${red}Belum ada user SSH VPN yang online.${NC}"
  echo ""
  rm -f "$tmpfile"
  read -p "$( echo -e "Press ${orange}[ ${NC}${green}Enter${NC} ${CYAN}]${NC} kembali ke menu . . .") "
  menu
fi

# Tampilkan per user
for u in "${vpn_users[@]}"; do
  iplist=( $(awk -v usr="$u" '$1==usr {print $2}' "$tmpfile" | sort -u) )
  if [[ ${#iplist[@]} -gt 0 ]]; then
    echo -e "User : $u"
    printf "%s\n" "${iplist[@]}" | nl -ba
    echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
  fi
done

rm -f "$tmpfile"

echo ""
read -p "$( echo -e "Press ${orange}[ ${NC}${green}Enter${NC} ${CYAN}]${NC} kembali ke menu . . .") "
menu

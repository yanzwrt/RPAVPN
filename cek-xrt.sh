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

# kosongkan file temp
> /tmp/other.txt

# ambil list user dari xtrojan.json
data=( $(grep '^###' /usr/local/etc/xray/xtrojan.json | awk '{print $2}' | sort -u) )

echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e " \E[0;47;30m  XRAY TROJAN TCP XTLS User Login  \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# pastikan log ada
if [[ ! -f /var/log/xray/access5.log ]]; then
    echo -e "${red}Log /var/log/xray/access5.log tidak ditemukan.${NC}"
    echo ""
    read -p "$( echo -e "Press ${orange}[ ${NC}${green}Enter${NC} ${CYAN}]${NC} Back to menu . . .") "
    menu
fi

for akun in "${data[@]}"; do
    [[ -z "$akun" ]] && continue

    > /tmp/iptrojanxrt.txt

    # ambil IP unik dari log XTLS
    data2=( $(tail -n 500 /var/log/xray/access5.log | \
              awk '{print $3}' | sed 's/tcp://g' | cut -d ":" -f 1 | sort -u) )

    for ip in "${data2[@]}"; do
        # cek apakah IP ini dipakai user $akun
        jum=$(grep -w "$akun" /var/log/xray/access5.log | tail -n 500 | \
              awk '{print $3}' | sed 's/tcp://g' | cut -d ":" -f 1 | \
              grep -w "$ip" | sort -u)

        if [[ "$jum" == "$ip" ]]; then
            echo "$jum" >> /tmp/iptrojanxrt.txt
        else
            echo "$ip" >> /tmp/other.txt
        fi
    done

    if [[ -s /tmp/iptrojanxrt.txt ]]; then
        echo "User : $akun"
        nl -ba /tmp/iptrojanxrt.txt
        echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    fi

    rm -f /tmp/iptrojanxrt.txt
done

rm -f /tmp/other.txt

echo ""
read -p "$( echo -e "Press ${orange}[ ${NC}${green}Enter${NC} ${CYAN}]${NC} Back to menu . . .") "
menu

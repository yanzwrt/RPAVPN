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

clear
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
echo -e "\\E[0;47;30m         L2TP/IPSec User Login       \E[0m"
echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

# Pastikan file chap-secrets ada (daftar user L2TP/IPsec)
if [[ ! -f /etc/ppp/chap-secrets ]]; then
    echo ""
    echo -e "${red}File /etc/ppp/chap-secrets tidak ditemukan.${NC}"
    echo -e "${yellow}L2TP/IPsec sepertinya belum terpasang dengan benar.${NC}"
    echo ""
    read -n1 -r -p "Press [ Enter ] kembali ke menu . . . "
    exit 0
fi

# Ambil list user dari chap-secrets (abaikan baris kosong & komentar)
mapfile -t USERS < <(awk '!/^#/ && NF>=3 {print $1}' /etc/ppp/chap-secrets | sort -u)

if [[ ${#USERS[@]} -eq 0 ]]; then
    echo ""
    echo -e "${yellow}Belum ada user L2TP yang dibuat di /etc/ppp/chap-secrets.${NC}"
    echo ""
    read -n1 -r -p "Press [ Enter ] kembali ke menu . . . "
    exit 0
fi

# Kumpulkan log ke file sementara (gabung journalctl + file log)
TMP_LOG=$(mktemp)

# 1) Dari journalctl (service yang umum dipakai L2TP/IPsec)
if command -v journalctl >/dev/null 2>&1; then
    journalctl -u xl2tpd -u ipsec -u strongswan-starter -u strongswan -u pppd \
        --no-pager -n 2000 2>/dev/null >> "$TMP_LOG"
fi

# 2) Dari file log klasik, kalau ada
for LOGF in /var/log/auth.log /var/log/syslog /var/log/daemon.log /var/log/ppp.log; do
    [[ -f "$LOGF" ]] && tail -n 2000 "$LOGF" >> "$TMP_LOG"
done

if [[ ! -s "$TMP_LOG" ]]; then
    echo ""
    echo -e "${yellow}Tidak ada log L2TP yang bisa dibaca (journalctl & file log kosong / tidak ada).${NC}"
    echo ""
    rm -f "$TMP_LOG"
    read -n1 -r -p "Press [ Enter ] kembali ke menu . . . "
    exit 0
fi

echo ""
FOUND_ANY=0

# Cari aktivitas tiap user di log gabungan
for user in "${USERS[@]}"; do
    # Pola umum: pppd/xl2tpd/ipsec/strongswan + username
    LAST_LINE=$(grep -Ei "pppd|xl2tpd|l2tp|ipsec|strongswan" "$TMP_LOG" | grep -Ei "$user" | tail -n 1)

    if [[ -n "$LAST_LINE" ]]; then
        FOUND_ANY=1
        echo -e " ${green}• User${NC} : ${yellow}$user${NC}"
        echo -e "   Log : $LAST_LINE"
        echo ""
    fi
done

rm -f "$TMP_LOG"

if [[ $FOUND_ANY -eq 0 ]]; then
    echo ""
    echo -e "${yellow}Belum ada aktivitas login L2TP yang tercatat (2000 baris log terakhir).${NC}"
    echo ""
fi

read -n1 -r -p "Press [ Enter ] kembali ke menu . . . "

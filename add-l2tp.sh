#!/bin/bash
# =========================================
# RPAVPN | Add L2TP User
# Mod By: yanzwrt
# =========================================

NC='\e[0m'
RED='\e[31;1m'
GREEN='\e[32;1m'
YELLOW='\e[33;1m'
BLUE='\e[34;1m'
CYAN='\e[36;1m'
WHITE='\e[37;1m'

clear
dateFromServer=$(curl -s --insecure https://google.com/ | grep Date | sed -e 's/< Date: //')
biji=$(date +"%Y-%m-%d" -d "$dateFromServer")

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}            ⇱ Buat Akun L2TP ⇲         ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# === Username ===
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${user_EXISTS} == '0' ]]; do
    read -rp "➤ Username : " user
    user_EXISTS=$(grep -w "$user" /etc/ppp/chap-secrets | wc -l)

    if [[ ${user_EXISTS} == '1' ]]; then
        echo -e "${RED}✖ Username sudah terdaftar!${NC}"
        exit 1
    fi
done

read -rp "➤ Password : " pass
read -rp "➤ IPsec PSK (shared key) : " psk
read -rp "➤ Masa aktif (hari) : " masaaktif

hariini=$(date +"%Y-%m-%d")
exp=$(date -d "$masaaktif days" +"%Y-%m-%d")

IP=$(curl -s ifconfig.me)
domain=$(cat /root/domain)

# === Add L2TP User ===
echo "$user l2tpd $pass *" >> /etc/ppp/chap-secrets
echo "$user:$pass" | chpasswd >/dev/null 2>&1

# === Add IPSec User ===
echo "$user:$pass:xauth-psk" >> /etc/ipsec.d/passwd

# === Output ===
clear
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}            Detail Akun L2TP          ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "👤 Username : $user"
echo -e "🔑 Password : $pass"
echo -e "🔐 PSK Key  : $psk"
echo -e "🌐 Server   : $IP / $domain"
echo -e "📆 Dibuat   : $hariini"
echo -e "⏳ Expired  : $exp"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "Port L2TP   : 1701"
echo -e "Port IPSec  : 500, 4500"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "✨ Script by RPAVPN"
echo ""
read -n 1 -s -r -p "Tekan ENTER untuk kembali ke menu..."
menu

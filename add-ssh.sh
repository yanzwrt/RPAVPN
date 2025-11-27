#!/bin/bash
# =========================================
# RPAVPN | Add SSH User
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
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}       ⇱ Buat Akun SSH Premium ⇲       ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# === Username ===
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${user_EXISTS} == '0' ]]; do
    read -rp "➤ Username        : " user
    user_EXISTS=$(grep -w "^$user" /etc/passwd | wc -l)

    if [[ $user_EXISTS == 1 ]]; then
        echo -e "${RED}✖ Username sudah digunakan!${NC}"
        exit 1
    fi
done

# === Password & Masa Aktif ===
read -rp "➤ Password        : " pass
read -rp "➤ Masa aktif (hari) : " masaaktif

exp=$(date -d "$masaaktif days" +"%Y-%m-%d")
hariini=$(date +"%Y-%m-%d")

# === Add User ===
useradd -e $exp -s /bin/false -M $user
echo -e "$pass\n$pass" | passwd $user &> /dev/null

IP=$(curl -s ifconfig.me)
domain=$(cat /root/domain)

sshws_port=$(cat /etc/ssh/sshws-port 2>/dev/null)
[[ -z $sshws_port ]] && sshws_port="80"

# === Output ===
clear
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}          Detail Akun SSH             ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "👤 Username      : $user"
echo -e "🔑 Password      : $pass"
echo -e "🌐 Host/IP       : $IP"
echo -e "🌍 Domain        : $domain"
echo -e "🕓 Port OpenSSH  : 22"
echo -e "🕓 Port Dropbear : 109, 143"
echo -e "🕓 Port SSH WS   : $sshws_port"
echo -e "📆 Dibuat       : $hariini"
echo -e "⏳ Expired      : $exp"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "✨ Script by RPAVPN"
echo ""
read -n 1 -s -r -p "Tekan ENTER untuk kembali ke menu..."
menu

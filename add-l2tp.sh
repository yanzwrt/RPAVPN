#!/bin/bash
# =========================================
# RPAVPN | Tambah Akun L2TP/IPSec PSK
# Edisi   : Stable Edition V1.0
# Mod     : yanzwrt (base RakhaVPN)
# =========================================

clear
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=$(date +"%Y-%m-%d" -d "$dateFromServer")

# WARNA
NC='\e[0m'
RB='\e[31;1m'
GB='\e[32;1m'
YB='\e[33;1m'
BB='\e[34;1m'
WB='\e[37;1m'

MYIP=$(curl -sS ifconfig.me)
domain=$(cat /root/domain)

# Ambil PSK dari /etc/ipsec.secrets (kalau ada)
psk=$(grep -v "^#" /etc/ipsec.secrets 2>/dev/null | awk 'NF && $0 !~ /\/etc\/ipsec.secrets/ {print $NF}' | sed 's/"//g' | head -n1)
[[ -z "$psk" ]] && psk="(cek di /etc/ipsec.secrets)"

# FORM INPUT USER
clear
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${user_EXISTS} == '0' ]]; do
    echo -e "${BB}════════════════════════════════════════════════${NC}"
    echo -e "${WB}              🛰 Tambah Akun L2TP              ${NC}"
    echo -e "${BB}════════════════════════════════════════════════${NC}"

    read -rp "➤ Masukkan Username : " -e user
    user_EXISTS=$(grep -w "$user" /etc/ppp/chap-secrets 2>/dev/null | wc -l)

    if [[ ${user_EXISTS} == '1' ]]; then
        echo -e "${RB}⚠️  Username sudah terdaftar. Silakan gunakan nama lain.${NC}"
        read -n 1 -s -r -p "$(echo -e "${YB}Tekan tombol apa saja untuk kembali${NC}")"
        menu
    fi
done

read -rp "➤ Masukkan Password : " -e pass
[[ -z "$pass" ]] && pass="$user"

read -rp "➤ Masa Aktif (hari) : " masaaktif

hariini=$(date +"%Y-%m-%d")
exp=$(date -d "$masaaktif days" +"%Y-%m-%d")

# TAMBAH KE CHAP-SECRETS
# Format: "user"  service  "password"  ip
{
    echo "### $user $exp"
    echo "\"$user\" l2tpd \"$pass\" *"
} >> /etc/ppp/chap-secrets

# OUTPUT
clear
echo -e "${BB}════════════════════════════════════════════════${NC}"
echo -e "${WB}              Detail Akun L2TP/IPSec            ${NC}"
echo -e "${BB}════════════════════════════════════════════════${NC}"
echo -e "👤 Username         : ${user}"
echo -e "🔑 Password         : ${pass}"
echo -e "🔐 IPSec PSK        : ${psk}"
echo -e "🌐 IP VPS           : ${MYIP}"
echo -e "🌍 Domain           : ${domain}"
echo -e "${BB}════════════════════════════════════════════════${NC}"
echo -e "🕓 Port L2TP        : 1701"
echo -e "🕓 Port IPSec       : 500, 4500"
echo -e "${BB}════════════════════════════════════════════════${NC}"
echo -e "📆 Tanggal Dibuat   : ${hariini}"
echo -e "⏳ Expired Pada     : ${exp}"
echo -e "${BB}════════════════════════════════════════════════${NC}"
echo -e "✨ Script L2TP by RPAVPN"
echo ""
read -p "$(echo -e "${YB}Tekan Enter untuk kembali ke menu ...${NC}")"
menu

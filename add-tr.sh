#!/bin/bash
# add-tr.sh - XRAY TROJAN WS (TLS / NTLS) FULL SNI SUPPORT
# FIXED VERSION FOR RPAVPN (config.json single file)

clear
NC='\e[0m'; RB='\e[31;1m'; GB='\e[32;1m'; YB='\e[33;1m'; BB='\e[34;1m'; WB='\e[37;1m'

domain=$(cat /root/domain 2>/dev/null)
MYIP=$(curl -sS ifconfig.me)

config="/etc/xray/config.json"

echo -e "${BB}════════════════════════════════════════════════${NC}"
echo -e "${WB}      🛡️ Tambah Akun XRAY TROJAN WS (SNI) 🛡️    ${NC}"
echo -e "${BB}════════════════════════════════════════════════${NC}"

# USERNAME
until [[ $user =~ ^[a-zA-Z0-9_]+$ ]]; do
  read -rp "➤ Masukkan Username : " -e user
done

# BUG & SNI
read -rp "➤ Bug Address (ex: www.google.com) : " address
read -rp "➤ Bug SNI/Host (ex: m.youtube.com) : " sni
read -rp "➤ Masa Aktif (hari) : " masaaktif

[[ -z $address ]] && address="${domain}"
[[ -z $sni ]] && sni="${domain}"

exp=$(date -d "+${masaaktif} days" +"%Y-%m-%d")
hariini=$(date +"%Y-%m-%d")
password="${user}"

# ============================================================
# INSERT INTO /etc/xray/config.json
# ============================================================

if grep -q '#trojan-ws' "$config"; then
  sed -i "/#trojan-ws/a \      {\"password\": \"${password}\", \"email\": \"${user}\"}," "$config"
else
  echo "[ERROR] Marker #trojan-ws tidak ditemukan!"
  exit 1
fi

# Restart Xray
systemctl restart xray
systemctl restart nginx

# =============================
# LINKS
# =============================

trojan_tls="trojan://${password}@${address}:${domain}:443?type=ws&security=tls&host=${sni}&path=%2Ftrojan&sni=${sni}#XRAY-TROJAN-TLS-${user}"
trojan_ntls="trojan://${password}@${address}:${domain}:80?type=ws&security=none&host=${sni}&path=%2Ftrojan#XRAY-TROJAN-NTLS-${user}"

# =============================
# OUTPUT
# =============================

clear
echo -e "${BB}════════════════════════════════════════════════${NC}"
echo -e "${WB}            Detail Akun XRAY TROJAN WS          ${NC}"
echo -e "${BB}════════════════════════════════════════════════${NC}"
echo -e "📌 Username         : ${user}"
echo -e "🌐 Domain           : ${domain}"
echo -e "📡 Bug Address      : ${address}"
echo -e "🔒 SNI / Host       : ${sni}"
echo -e "🔑 Password         : ${password}"
echo -e "🔒 Port TLS         : 443"
echo -e "🔓 Port Non-TLS     : 80"
echo -e "🔁 Network          : ws"
echo -e "📄 Path             : /trojan"
echo -e "📆 Dibuat           : ${hariini}"
echo -e "⏳ Expired          : ${exp}"
echo -e "${BB}════════════════════════════════════════════════${NC}"
echo -e "🔗 Link TLS :"
echo -e "${trojan_tls}"
echo -e "${BB}════════════════════════════════════════════════${NC}"
echo -e "🔗 Link Non-TLS :"
echo -e "${trojan_ntls}"
echo -e "${BB}════════════════════════════════════════════════${NC}"

read -p "$(echo -e "${YB}Tekan Enter untuk kembali ke menu ...${NC}")"

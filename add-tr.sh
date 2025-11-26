#!/bin/bash
# add-tr.sh - Add XRAY Trojan WS TLS & NTLS (FULL SNI SUPPORT)

clear
NC='\e[0m'; RB='\e[31;1m'; GB='\e[32;1m'; YB='\e[33;1m'; BB='\e[34;1m'; WB='\e[37;1m'

domain=$(cat /root/domain 2>/dev/null)
MYIP=$(curl -sS ifconfig.me)

echo -e "${BB}════════════════════════════════════════════════${NC}"
echo -e "${WB}      🛡️ Tambah Akun XRAY TROJAN WS (SNI) 🛡️    ${NC}"
echo -e "${BB}════════════════════════════════════════════════${NC}"

# read username
until [[ $user =~ ^[a-zA-Z0-9_]+$ ]]; do
  read -rp "➤ Masukkan Username (Password) : " -e user
done

# bug address + sni
read -rp "➤ Bug Address (ex: www.google.com) : " address
read -rp "➤ Bug SNI/Host (ex: m.youtube.com) : " sni
read -rp "➤ Masa Aktif (hari) : " masaaktif

[[ -z $address ]] && address="${domain}"
[[ -z $sni ]] && sni="${domain}"

exp=$(date -d "+${masaaktif} days" +"%Y-%m-%d")
hariini=$(date +"%Y-%m-%d")

password="${user}"

# ============================================================
# INSERT INTO trojanws.json (TLS)
# ============================================================

file1="/usr/local/etc/xray/trojanws.json"

if grep -q "#tr" "$file1"; then
sed -i '/#tr/a\      {"password": "'$password'","email": "'$user'","expiry": "'$exp'"},' $file1
else
echo "[ERROR] Marker #tr tidak ditemukan di trojanws.json"
fi

# ============================================================
# INSERT INTO trnone.json (NON-TLS)
# ============================================================

file2="/usr/local/etc/xray/trnone.json"

if grep -q "#trnone" "$file2"; then
sed -i '/#trnone/a\      {"password": "'$password'","email": "'$user'","expiry": "'$exp'"},' $file2
else
echo "[ERROR] Marker #trnone tidak ditemukan di trnone.json"
fi

# restart services
systemctl restart xray@trojanws 2>/dev/null
systemctl restart xray@trnone 2>/dev/null
systemctl restart nginx 2>/dev/null
service cron restart 2>/dev/null

# LINKS (SNI SUPPORT)
trojan_tls="trojan://${password}@${address}.${domain}:443?type=ws&security=tls&host=${sni}&path=%2Ftrojan&sni=${sni}#XRAY-TROJAN-TLS-${user}"
trojan_ntls="trojan://${password}@${address}.${domain}:80?type=ws&security=none&host=${sni}&path=%2Ftrojan#XRAY-TROJAN-NTLS-${user}"

# ============================================================
# OUTPUT
# ============================================================

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
echo -e "🔗 Link TLS         : ${trojan_tls}"
echo -e "${BB}════════════════════════════════════════════════${NC}"
echo -e "🔗 Link Non-TLS     : ${trojan_ntls}"
echo -e "${BB}════════════════════════════════════════════════${NC}"
read -p "$(echo -e "${YB}Tekan Enter untuk kembali ke menu ...${NC}")"

#!/bin/bash
# =========================================
# RPAVPN | Tambah Akun SSH
# Edisi   : Stable Edition V1.0
# Mod     : yanzwrt (base RakhaVPN)
# =========================================

clear
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=$(date +"%Y-%m-%d" -d "$dateFromServer")

# WARNA
NC='\e[0m'
RB='\e[31;1m' # Merah
GB='\e[32;1m' # Hijau
YB='\e[33;1m' # Kuning
BB='\e[34;1m' # Biru
WB='\e[37;1m' # Putih

MYIP=$(curl -sS ifconfig.me)
domain=$(cat /root/domain)

# Cek port OpenSSH
openssh_port=$(grep -i "^Port " /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}' | xargs)
[[ -z "$openssh_port" ]] && openssh_port="22"

# Port Dropbear (default RPAVPN)
dropbear_port="109, 143"

# Port SSH WebSocket (RPAVPN pakai 80)
sshws_port="80"

# FORM INPUT USER
clear
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${user_EXISTS} == '0' ]]; do
    echo -e "${BB}════════════════════════════════════════════════${NC}"
    echo -e "${WB}            🧩 Tambah Akun SSH Premium          ${NC}"
    echo -e "${BB}════════════════════════════════════════════════${NC}"

    read -rp "➤ Masukkan Username : " -e user
    user_EXISTS=$(grep -w "^$user" /etc/passwd | wc -l)

    if [[ ${user_EXISTS} == '1' ]]; then
        echo -e "${RB}⚠️  Username sudah terdaftar. Silakan gunakan nama lain.${NC}"
        read -n 1 -s -r -p "$(echo -e "${YB}Tekan tombol apa saja untuk kembali${NC}")"
        menu
    fi
done

read -rp "➤ Masukkan Password : " -e pass
[[ -z "$pass" ]] && pass="$user"

read -rp "➤ Masa Aktif (hari) : " masaaktif

exp=$(date -d "$masaaktif days" +"%Y-%m-%d")
hariini=$(date +"%Y-%m-%d")

# BUAT USER SSH
useradd -e "$exp" -s /bin/false -M "$user"
echo -e "$pass\n$pass" | passwd "$user" &> /dev/null

# OUTPUT
clear
echo -e "${BB}════════════════════════════════════════════════${NC}"
echo -e "${WB}                Detail Akun SSH                 ${NC}"
echo -e "${BB}════════════════════════════════════════════════${NC}"
echo -e "👤 Username         : ${user}"
echo -e "🔑 Password         : ${pass}"
echo -e "🌐 IP VPS           : ${MYIP}"
echo -e "🌍 Domain           : ${domain}"
echo -e "${BB}════════════════════════════════════════════════${NC}"
echo -e "🕓 Port OpenSSH     : ${openssh_port}"
echo -e "🕓 Port Dropbear    : ${dropbear_port}"
echo -e "🕓 Port SSH WS      : ${sshws_port}"
echo -e "${BB}════════════════════════════════════════════════${NC}"
echo -e "📆 Tanggal Dibuat   : ${hariini}"
echo -e "⏳ Expired Pada     : ${exp}"
echo -e "${BB}════════════════════════════════════════════════${NC}"
echo -e "💡 Payload WS (contoh):"
echo -e "   GET / HTTP/1.1"
echo -e "   Host: ${domain}"
echo -e "   Upgrade: websocket"
echo -e "   Connection: Upgrade"
echo -e "${BB}════════════════════════════════════════════════${NC}"
echo -e "✨ Script SSH by RPAVPN"
echo ""
read -p "$(echo -e "${YB}Tekan Enter untuk kembali ke menu ...${NC}")"
menu

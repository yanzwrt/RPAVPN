#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition V1.1
# Author  : yanzwrt
# (C) Copyright 2025
# =========================================

clear

# Warna
DEFBOLD='\e[39;1m'
RB='\e[31;1m'
GB='\e[32;1m'
YB='\e[33;1m'
BB='\e[34;1m'
MB='\e[35;1m'
CB='\e[35;1m'
WB='\e[37;1m'
red='\e[1;31m'
green='\e[0;32m'
purple='\e[0;35m'
orange='\e[0;33m'
CYAN='\e[0;36m'
NC='\e[0m'

# URL repo
export Server_URL="raw.githubusercontent.com/yanzwrt/RPAVPN/main"

# Ambil tanggal dari server Google
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=$(date +"%Y-%m-%d" -d "$dateFromServer")

# IP VPS (pakai satu saja, yang stabil)
MYIP=$(curl -sS ifconfig.me)

echo "Checking VPS..."
sleep 1
clear

# Cek harus root
if [ "${EUID}" -ne 0 ]; then
  echo "Anda perlu menjalankan skrip ini sebagai root"
  exit 1
fi

# Cek OpenVZ
if [ "$(systemd-detect-virt)" == "openvz" ]; then
  echo "OpenVZ tidak didukung"
  exit 1
fi

# Fungsi durasi instalasi
secs_to_human() {
  echo "Waktu instalasi : $(( ${1} / 3600 )) jam $(( (${1} / 60) % 60 )) menit $(( ${1} % 60 )) detik"
}

start=$(date +%s)

echo -e "[ ${green}INFO${NC} ] Mempersiapkan instalasi autoscript ~"
apt install git curl -y >/dev/null 2>&1
echo -e "[ ${green}INFO${NC} ] File instalasi siap untuk dimulai!"
sleep 1

# =========================================
# ENABLE IP FORWARD + IPTABLES UNTUK VPN
# =========================================
echo -e "[ ${green}INFO${NC} ] Mengaktifkan IPv4 forwarding..."
sed -i 's/^#\?net.ipv4.ip_forward=.*/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sysctl -p >/dev/null 2>&1

# Deteksi interface publik (eth0 / ens3 / ens18, dll)
WAN_IF=$(ip route show default 2>/dev/null | awk '{print $5}' | head -n1)
if [ -z "$WAN_IF" ]; then
  WAN_IF="eth0"
fi
echo -e "[ ${green}INFO${NC} ] Interface publik terdeteksi: ${WAN_IF}"

echo -e "[ ${green}INFO${NC} ] Mengatur iptables NAT & FORWARD untuk klien VPN (ppp+/L2TP)..."

# NAT semua trafik keluar via interface publik
iptables -t nat -A POSTROUTING -o "${WAN_IF}" -j MASQUERADE

# Izinkan trafik dari klien L2TP/PPP (ppp+) ke internet
iptables -A FORWARD -i ppp+ -o "${WAN_IF}" -j ACCEPT

# Izinkan trafik balik dari internet ke klien L2TP/PPP
iptables -A FORWARD -i "${WAN_IF}" -o ppp+ -m state --state RELATED,ESTABLISHED -j ACCEPT

# Install & simpan iptables-persistent agar rules tidak hilang saat reboot
apt-get install -y iptables-persistent >/dev/null 2>&1
netfilter-persistent save >/dev/null 2>&1
echo -e "[ ${green}INFO${NC} ] Aturan iptables tersimpan (iptables-persistent)."

# Cek apakah sudah pernah diinstall (pakai config Xray & domain)
if [ -f "/usr/local/etc/xray/config.json" ] && [ -f "/root/domain" ]; then
  echo "Skrip sudah terpasang. Jika ingin install ulang, hapus /usr/local/etc/xray dan /root/domain dulu."
  exit 0
fi

# Direktori data
mkdir -p /var/lib/premium-script
mkdir -p /var/lib/crot-script

clear
echo -e "${red}    ♦️${NC} ${green}PENYIAPAN DOMAIN VPS${NC}"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m${NC}"
echo "1. Gunakan Domain Dari Script (Cloudflare API di cf.sh)"
echo "2. Masukkan Domain Sendiri (sudah kamu pointing ke IP VPS)"
echo -e "${red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m${NC}"
read -rp "Pilih Instalasi Domain Anda [1/2] : " dom

host=""

case "$dom" in
  1)
    clear
    wget -q -O /root/cf.sh "https://${Server_URL}/cf.sh"
    chmod +x /root/cf.sh
    /root/cf.sh
    # cf.sh seharusnya menulis domain ke /root/domain
    if [ -f /root/domain ]; then
      host=$(cat /root/domain)
    else
      echo "Gagal mendapatkan domain dari cf.sh"
      exit 1
    fi
    ;;
  2)
    read -rp "Masukkan Domain Anda : " domen
    if [ -z "$domen" ]; then
      echo "Domain tidak boleh kosong!"
      exit 1
    fi
    echo "$domen" > /root/domain
    host="$domen"
    ;;
  *)
    echo "Pilihan tidak valid, keluar."
    exit 1
    ;;
esac

echo -e "${green}Done!${NC}"
sleep 1
clear

# Simpan IP/host ke file config
echo "IP=$host" > /var/lib/premium-script/ipvps.conf
echo "IP=$host" > /var/lib/crot-script/ipvps.conf

# Pastikan /root/domain berisi domain terakhir yang dipakai
echo "$host" > /root/domain

# ==============================
# Instal SSH + WebSocket + Dropbear
# ==============================
echo -e "\e[0;32mINSTALLING SSH-VPN...\e[0m"
sleep 1
wget -q -O /root/ssh-vpn.sh "https://${Server_URL}/ssh-vpn.sh"
chmod +x /root/ssh-vpn.sh
/root/ssh-vpn.sh
echo -e "${green}Done!${NC}"
sleep 2
clear

# ==============================
# Instal XRAY CORE (VMESS/VLESS/TROJAN WS + XTLS)
# ==============================
echo -e "\e[0;32mINSTALLING XRAY CORE...\e[0m"
sleep 1
wget -q -O /root/xray.sh "https://${Server_URL}/xray.sh"
chmod +x /root/xray.sh
/root/xray.sh
echo -e "${green}Done!${NC}"
sleep 2
clear

# ==============================
# Install Set-BR (iptables, banner, dsb)
# ==============================
echo -e "\e[0;32mINSTALLING SET-BR...\e[0m"
sleep 1
wget -q -O /root/set-br.sh "https://${Server_URL}/set-br.sh"
chmod +x /root/set-br.sh
/root/set-br.sh
echo -e "${green}Done!${NC}"
sleep 2
clear

# ==============================
# Install L2TP/IPsec
# ==============================
echo -e "\e[0;32mINSTALLING L2TP/IPSEC...\e[0m"
sleep 1
wget -q -O /root/l2tp.sh "https://${Server_URL}/l2tp.sh"
chmod +x /root/l2tp.sh
/root/l2tp.sh
echo -e "${green}Done!${NC}"
sleep 2
clear

# Bersihkan file installer
rm -f /root/xray.sh
rm -f /root/set-br.sh
rm -f /root/ssh-vpn.sh
rm -f /root/l2tp.sh
rm -f /root/cf.sh 2>/dev/null

# Simpan versi script
echo "1.0" > /home/ver

clear
echo ""
echo -e "${RB}      .-------------------------------------------.${NC}"
echo -e "${RB}      |${NC}      ${CB}Instalasi Telah Selesai${NC}      ${RB}|${NC}"
echo -e "${RB}      '-------------------------------------------'${NC}"
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e "      ${WB}Multiport Websocket Autoscript By RAKHA-VPN${NC}"
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e "  ${WB}»»» Protocol Service «««  |  »»» Network Protocol «««${NC}  "
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e "  ${RB}♦️${NC} ${YB}Vmess Websocket${NC}         ${WB}|${NC}  ${YB}- Websocket (CDN) TLS${NC}"
echo -e "  ${RB}♦️${NC} ${YB}Vless Websocket${NC}         ${WB}|${NC}  ${YB}- Websocket (CDN) NTLS${NC}"
echo -e "  ${RB}♦️${NC} ${YB}Trojan Websocket${NC}        ${WB}|${NC}  ${YB}- TCP XTLS${NC}"
echo -e "  ${RB}♦️${NC} ${YB}Trojan TCP XTLS${NC}         ${WB}|${NC}  ${YB}- TCP TLS${NC}"
echo -e "  ${RB}♦️${NC} ${YB}Trojan TCP${NC}              ${WB}|${NC}"
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e "           ${WB}»»» YAML Service Information «««${NC}          "
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e "  ${RB}♦️${NC} ${YB}YAML XRAY VMESS WS${NC}"
echo -e "  ${RB}♦️${NC} ${YB}YAML XRAY VLESS WS${NC}"
echo -e "  ${RB}♦️${NC} ${YB}YAML XRAY TROJAN WS${NC}"
echo -e "  ${RB}♦️${NC} ${YB}YAML XRAY TROJAN XTLS${NC}"
echo -e "  ${RB}♦️${NC} ${YB}YAML XRAY TROJAN TCP${NC}"
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e "             ${WB}»»» Server Information «««${NC}                 "
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e "  ${RB}♦️${NC} ${YB}Timezone                : Asia/Jakarta (GMT +7)${NC}"
echo -e "  ${RB}♦️${NC} ${YB}Fail2Ban                : [ON]${NC}"
echo -e "  ${RB}♦️${NC} ${YB}Dflate                  : [ON]${NC}"
echo -e "  ${RB}♦️${NC} ${YB}IPtables                : [ON]${NC}"
echo -e "  ${RB}♦️${NC} ${YB}Auto-Reboot             : [ON]${NC}"
echo -e "  ${RB}♦️${NC} ${YB}IPV6                    : [OFF]${NC}"
echo -e ""
echo -e "  ${RB}♦️${NC} ${YB}Autoreboot On 03.00 WIB GMT +7${NC}"
echo -e "  ${RB}♦️${NC} ${YB}Backup & Restore VPS Data${NC}"
echo -e "  ${RB}♦️${NC} ${YB}Automatic Delete Expired Account${NC}"
echo -e "  ${RB}♦️${NC} ${YB}Bandwith Monitor${NC}"
echo -e "  ${RB}♦️${NC} ${YB}RAM & CPU Monitor${NC}"
echo -e "  ${RB}♦️${NC} ${YB}Check Login User${NC}"
echo -e "  ${RB}♦️${NC} ${YB}Check Created Config${NC}"
echo -e "  ${RB}♦️${NC} ${YB}Automatic Clear Log${NC}"
echo -e "  ${RB}♦️${NC} ${YB}Media Checker${NC}"
echo -e "  ${RB}♦️${NC} ${YB}DNS Changer${NC}"
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e "              ${WB}»»» Network Port Service «««${NC}             "
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo -e "  ${RB}♦️${NC} ${YB}HTTP                    : 80, 8080, 8880${NC}"
echo -e "  ${RB}♦️${NC} ${YB}HTTPS                   : 443${NC}"
echo -e "${BB}————————————————————————————————————————————————————————${NC}"
echo ""

secs_to_human "$(($(date +%s) - ${start}))"
echo ""

# Hapus dirinya sendiri
rm -f setup.sh

echo ""
read -p "$( echo -e "Tekan ${orange}[ ${NC}${green}Enter${NC} ${orange}]${NC} untuk memulai ulang VPS...") " 
reboot

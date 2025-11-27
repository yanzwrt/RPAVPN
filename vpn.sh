#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition V1.0
# Auther  : RakhaVPN
# (C) Copyright 2025
# =========================================

# === Warna & Label ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'
NC='\033[0m'

EROR="[${RED} ERROR ${NC}]"
INFO="[${YELLOW} INFO ${NC}]"
OKEY="[${GREEN} OKEY ${NC}]"

BOLD="\e[1m"
UNDERLINE="\e[4m"

# === Cek Root ===
if [ "${EUID}" -ne 0 ]; then
    echo -e "${EROR} Jalankan script ini sebagai root!"
    exit 1
fi

# === Locale ===
export LC_ALL='en_US.UTF-8' > /dev/null
export LANG='en_US.UTF-8' > /dev/null
export LANGUAGE='en_US.UTF-8' > /dev/null
export LC_CTYPE='en_US.utf8' > /dev/null

# === Konfigurasi Repo & Variabel ===
# Folder ini silakan sesuaikan dengan struktur GitHub kamu
# Misal kamu taruh di: RPAVPN/OVPN/...
Server_URL_OVPN="https://raw.githubusercontent.com/yanzwrt/RPAVPN/main/OVPN"

Server_Port="443"
Script_Mode="Stable"
Auther="RakhaVPN"

# Domain dari autoscript kamu
if [[ -f /root/domain ]]; then
    domain=$(cat /root/domain)
else
    domain=$(curl -sS ipv4.icanhazip.com)
fi

# Interface publik
NET=$(ip route show default | awk '{print $5}' | head -n1)

# Placeholder untuk diganti di file .ovpn (xxxxxxxxx → domain)
MYIP2="s/xxxxxxxxx/$domain/g"

clear
echo -e "${YELLOW}========================================${NC}"
echo -e " ${GREEN}Instalasi & Konfigurasi OpenVPN (TCP/UDP/SSL)${NC}"
echo -e "${YELLOW}========================================${NC}"
sleep 1

# === Update & Dependensi ===
echo -e "${INFO} Update & upgrade paket..."
apt update -y
apt upgrade -y
apt dist-upgrade -y
apt autoremove -y
apt clean -y

echo -e "${INFO} Menginstall paket pendukung..."
apt install openvpn unzip -y
apt install openssl iptables iptables-persistent netfilter-persistent -y

# === Siapkan direktori OpenVPN ===
echo -e "${INFO} Menyiapkan direktori /etc/openvpn..."
rm -rf /etc/openvpn
mkdir -p /etc/openvpn
cd /etc/openvpn || exit 1

# === Download certificate bundle ===
echo -e "${INFO} Mengunduh certificate bundle OpenVPN..."
wget -q -O cert.zip "${Server_URL_OVPN}/OpenVPN-Certificate.zip"
if [[ ! -f cert.zip ]]; then
    echo -e "${EROR} Gagal mengunduh OpenVPN-Certificate.zip"
    exit 1
fi

unzip -o cert.zip >/dev/null 2>&1
rm -f cert.zip

mkdir -p config
rm -rf server client

# === Permission ===
chown -R root:root /etc/openvpn/

# === Plugin auth PAM ===
mkdir -p /usr/lib/openvpn/
if [[ -f /usr/lib/x86_64-linux-gnu/openvpn/plugins/openvpn-plugin-auth-pam.so ]]; then
    cp /usr/lib/x86_64-linux-gnu/openvpn/plugins/openvpn-plugin-auth-pam.so \
       /usr/lib/openvpn/openvpn-plugin-auth-pam.so
fi

# === Autostart OpenVPN ===
sed -i 's/#AUTOSTART="all"/AUTOSTART="all"/g' /etc/default/openvpn

# === Enable IPv4 Forward ===
echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf

# === Download server config TCP/UDP ===
echo -e "${INFO} Mengunduh konfigurasi server OpenVPN..."
wget -q -O /etc/openvpn/tcp.conf "${Server_URL_OVPN}/tcp.conf"
wget -q -O /etc/openvpn/udp.conf "${Server_URL_OVPN}/udp.conf"

if [[ ! -f /etc/openvpn/tcp.conf || ! -f /etc/openvpn/udp.conf ]]; then
    echo -e "${EROR} Gagal mengunduh tcp.conf atau udp.conf"
    exit 1
fi

# === Ganti service openvpn ===
rm -f /lib/systemd/system/openvpn-server@.service
wget -q -O /etc/systemd/system/openvpn@.service "${Server_URL_OVPN}/openvpn.service"

systemctl daemon-reload

# === Enable & Start OpenVPN TCP/UDP ===
systemctl stop openvpn@tcp 2>/dev/null
systemctl stop openvpn@udp 2>/dev/null
systemctl disable openvpn@tcp 2>/dev/null
systemctl disable openvpn@udp 2>/dev/null

systemctl enable openvpn@tcp
systemctl enable openvpn@udp
systemctl start openvpn@tcp
systemctl start openvpn@udp

# === Cek status TCP/UDP ===
echo -e "${YELLOW}==============================${NC}"
if [[ $(systemctl is-active openvpn@tcp) == "active" ]]; then
    echo -e "${OKEY} OpenVPN TCP Running!"
else
    echo -e "${EROR} OpenVPN TCP Tidak Berjalan!"
fi

if [[ $(systemctl is-active openvpn@udp) == "active" ]]; then
    echo -e "${OKEY} OpenVPN UDP Running!"
else
    echo -e "${EROR} OpenVPN UDP Tidak Berjalan!"
fi
echo -e "${YELLOW}==============================${NC}"
echo -e "${INFO} OpenVPN Daemon Service diaktifkan."

# === Download template client config ===
echo -e "${INFO} Mengunduh template config client (.ovpn)..."
cd /etc/openvpn/config || exit 1
wget -q -O tcp.ovpn "${Server_URL_OVPN}/tcp.ovpn"
wget -q -O udp.ovpn "${Server_URL_OVPN}/udp.ovpn"
wget -q -O ssl.ovpn "${Server_URL_OVPN}/ssl.ovpn"

if [[ ! -f tcp.ovpn || ! -f udp.ovpn || ! -f ssl.ovpn ]]; then
    echo -e "${EROR} Gagal mengunduh template .ovpn"
    exit 1
fi

# === Replace placeholder xxxxxxxxx dengan domain/host ===
sed -i "$MYIP2" /etc/openvpn/config/tcp.ovpn
sed -i "$MYIP2" /etc/openvpn/config/udp.ovpn
sed -i "$MYIP2" /etc/openvpn/config/ssl.ovpn

# === Embed CA ke dalam tiap file .ovpn ===
if [[ -f /etc/openvpn/ca.crt ]]; then
    echo '<ca>' >> /etc/openvpn/config/tcp.ovpn
    cat /etc/openvpn/ca.crt >> /etc/openvpn/config/tcp.ovpn
    echo '</ca>' >> /etc/openvpn/config/tcp.ovpn

    echo '<ca>' >> /etc/openvpn/config/udp.ovpn
    cat /etc/openvpn/ca.crt >> /etc/openvpn/config/udp.ovpn
    echo '</ca>' >> /etc/openvpn/config/udp.ovpn

    echo '<ca>' >> /etc/openvpn/config/ssl.ovpn
    cat /etc/openvpn/ca.crt >> /etc/openvpn/config/ssl.ovpn
    echo '</ca>' >> /etc/openvpn/config/ssl.ovpn
else
    echo -e "${EROR} /etc/openvpn/ca.crt tidak ditemukan!"
fi

# === Packaging ===
echo -e "${INFO} Membuat paket all.zip untuk client..."
zip -q all.zip tcp.ovpn udp.ovpn ssl.ovpn

# === Web directory (disamakan dengan YAML: /home/vps/public_html) ===
WEB_DIR="/home/vps/public_html"
mkdir -p "$WEB_DIR"

cp all.zip  "$WEB_DIR/all-openvpn.zip"
cp tcp.ovpn "$WEB_DIR/tcp.ovpn"
cp udp.ovpn "$WEB_DIR/udp.ovpn"
cp ssl.ovpn "$WEB_DIR/ssl.ovpn"

cd /root/ || exit 0

# === IP tables NAT & Port ===
echo -e "${INFO} Mengatur iptables NAT & port OpenVPN..."

iptables -t nat -I POSTROUTING -s 10.10.11.0/24 -o "$NET" -j MASQUERADE
iptables -t nat -I POSTROUTING -s 10.10.12.0/24 -o "$NET" -j MASQUERADE

iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 1194 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 1194 -j ACCEPT

iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 1195 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 1195 -j ACCEPT

iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 1196 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 1196 -j ACCEPT

iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules

netfilter-persistent save   >/dev/null 2>&1
netfilter-persistent reload >/dev/null 2>&1

# === Selesai ===
rm -f /root/vpn.sh

echo ""
echo -e "${GREEN}OpenVPN berhasil di-install & dikonfigurasi.${NC}"
echo -e "File config client bisa diunduh via:"
echo -e "  ${CYAN}http://${domain}:81/tcp.ovpn${NC}"
echo -e "  ${CYAN}http://${domain}:81/udp.ovpn${NC}"
echo -e "  ${CYAN}http://${domain}:81/ssl.ovpn${NC}"
echo -e "  ${CYAN}http://${domain}:81/all-openvpn.zip${NC}"
echo ""
echo -e "Script Mod By RakhaVPN"
echo ""

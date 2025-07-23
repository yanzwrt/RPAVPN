#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edisi   : Stable Edition V1.0
# Pembuat : Rakha-VPN
# =========================================

# === Warna ===
NC='\e[0m'
RED='\e[31;1m'
GREEN='\e[32;1m'
YELLOW='\e[33;1m'
BLUE='\e[34;1m'
PURPLE='\e[35;1m'
CYAN='\e[36;1m'
WHITE='\e[37;1m'

# === Info Tanggal ===
dateFromServer=$(curl -s --insecure https://google.com/ | grep Date | sed -e 's/< Date: //')
biji=$(date +"%Y-%m-%d" -d "$dateFromServer")

# === IP & Domain ===
MYIP=$(curl -s ipv4.icanhazip.com)
domain=$(cat /root/domain)

# === Header ===
clear
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}     ⇱ XRAY TROJAN TCP TLS ⇲            ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# === Input Username ===
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${user_EXISTS} == '0' ]]; do
	read -rp "$(echo -e "➤ ${CYAN}Username${NC}         : ") " -e user
	user_EXISTS=$(grep -w "$user" /usr/local/etc/xray/trojan.json | wc -l)

	if [[ ${user_EXISTS} == '1' ]]; then
		echo -e "${RED}✖ Username sudah terdaftar!${NC}"
		exit 1
	fi
done

# === Input Lainnya ===
read -rp "$(echo -e "➤ ${CYAN}Bug Address${NC}      : ") " -e address
read -rp "$(echo -e "➤ ${CYAN}SNI/Host Bug${NC}     : ") " -e hst
read -rp "$(echo -e "➤ ${CYAN}Expired (hari)${NC}   : ") " -e masaaktif

# === Logic Domain & SNI ===
bug_addr=${address}.
sts=${address:-$bug_addr}
sni=${hst:-$domain}
hariini=$(date -d "0 days" +"%Y-%m-%d")
exp=$(date -d "$masaaktif days" +"%Y-%m-%d")

# === Tambah User ke Config ===
sed -i "/#tr$/a\### ${user} ${exp}\
},{\"password\": \"${user}\",\"email\": \"${user}\"" /usr/local/etc/xray/trojan.json

# === Link Trojan ===
trojanlink="trojan://${user}@${sts}${domain}:443?security=tls&type=tcp&allowInsecure=1&sni=${sni}#XRAY_TROJAN_TCP_${user}"

# === Restart Service ===
systemctl restart xray@trojan.service
service cron restart

# === Generate File YAML ===
cat > /home/vps/public_html/$user-$exp-TRTCP.yaml <<EOF
port: 7890
socks-port: 7891
redir-port: 7892
mixed-port: 7893
tproxy-port: 7895
ipv6: false
mode: rule
log-level: silent
allow-lan: true
external-controller: 0.0.0.0:9090
secret: ""
bind-address: "*"
unified-delay: true
profile:
  store-selected: true
  store-fake-ip: true
dns:
  enable: true
  ipv6: false
  use-host: true
  enhanced-mode: fake-ip
  listen: 0.0.0.0:7874
  nameserver:
    - 8.8.8.8
    - 1.0.0.1
    - https://dns.google/dns-query
  fallback:
    - 1.1.1.1
    - 8.8.4.4
    - https://cloudflare-dns.com/dns-query
  default-nameserver:
    - 8.8.8.8
    - 1.1.1.1
  fake-ip-range: 198.18.0.1/16
  fake-ip-filter:
    - "*.lan"
    - "*.localdomain"
    - "*.example"
    - "*.invalid"
    - "*.localhost"
    - "*.test"
    - "*.local"
    - "*.home.arpa"
    - +.pool.ntp.org
proxies:
  - name: XRAY_TROJAN_TCP_${user}
    server: ${sts}${domain}
    port: 443
    type: trojan
    password: ${user}
    skip-cert-verify: true
    sni: ${sni}
    udp: true
proxy-groups:
  - name: RakhaVPN-AUTOSCRIPT
    type: select
    proxies:
      - XRAY_TROJAN_TCP_${user}
      - DIRECT
rules:
  - MATCH,RakhaVPN-AUTOSCRIPT
EOF

# === Output Akhir ===
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}          Detail Akun Trojan TCP        ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e " ${WHITE}Remarks${NC}       : ${user}"
echo -e " ${WHITE}Domain${NC}        : ${domain}"
echo -e " ${WHITE}IP/Host${NC}       : ${MYIP}"
echo -e " ${WHITE}Key/Password${NC}  : ${user}"
echo -e " ${WHITE}Port${NC}          : 443"
echo -e " ${WHITE}Network${NC}       : TCP"
echo -e " ${WHITE}Security${NC}      : TLS"
echo -e " ${WHITE}AllowInsecure${NC} : True"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e " ${WHITE}Dibuat${NC}        : $hariini"
echo -e " ${WHITE}Berakhir Pada${NC} : $exp"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e " ${WHITE}Link Trojan${NC}   : ${trojanlink}"
echo -e " ${WHITE}YAML Clash${NC}    : http://${MYIP}:81/$user-$exp-TRTCP.yaml"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e " ${CYAN}Script Mod By Rakha-VPN${NC}"
echo ""
read -p "$(echo -e "Tekan ${YELLOW}[Enter]${NC} untuk kembali ke menu...") "
menu

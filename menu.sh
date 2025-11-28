#!/bin/bash
clear
m="\033[0;1;36m"
y="\033[0;1;37m"
yy="\033[0;1;32m"
yl="\033[0;1;33m"
wh="\033[0m"

# Reset warna
NC='\e[0m'

## Foreground
DEFBOLD='\e[39;1m'
RB='\e[31;1m'
GB='\e[32;1m'
YB='\e[33;1m'
BB='\e[34;1m'
MB='\e[35;1m'
CB='\e[35;1m'
WB='\e[37;1m'

# CPU usage (pakai top biar simpel)
load_cpu=$(printf '%-3s' "$(top -bn1 2>/dev/null | awk '/Cpu/ { cpu = 100 - $8; printf("%.0f%%", cpu) }')")

# Domain & IP VPS
domain=$(cat /root/domain 2>/dev/null)
IPVPS=$(curl -sS ipv4.icanhazip.com 2>/dev/null || curl -sS ifconfig.me 2>/dev/null)

# Uptime OS
uptime="$(uptime -p | cut -d " " -f 2-10)"

# Info RAM
tram=$(free -m | awk 'NR==2 {print $2}')
uram=$(free -m | awk 'NR==2 {print $3}')

# Total Akun XRAYS
vmess=$(grep -c -E "^### " "/usr/local/etc/xray/config.json" 2>/dev/null)
vless=$(grep -c -E "^### " "/usr/local/etc/xray/vless.json" 2>/dev/null)
trws=$(grep -c -E "^### " "/usr/local/etc/xray/trojanws.json" 2>/dev/null)
txtls=$(grep -c -E "^### " "/usr/local/etc/xray/xtrojan.json" 2>/dev/null)
tr=$(grep -c -E "^### " "/usr/local/etc/xray/trojan.json" 2>/dev/null)

# Total akun SSH (user UID >= 1000, exclude nobody)
ssh_users=$(awk -F: '$3>=1000 && $1!="nobody"{c++} END{print c+0}' /etc/passwd 2>/dev/null)

# Total akun L2TP (pakai data-user-l2tp kalau ada, fallback ke chap-secrets)
l2tp_users=0
if [ -f /var/lib/premium-script/data-user-l2tp ]; then
  l2tp_users=$(wc -l < /var/lib/premium-script/data-user-l2tp 2>/dev/null)
elif [ -f /etc/ppp/chap-secrets ]; then
  l2tp_users=$(grep -cvE '^\s*($|#)' /etc/ppp/chap-secrets 2>/dev/null)
fi

# Total Bandwidth (vnstat)
daily_usage=$(vnstat -d --oneline 2>/dev/null | awk -F\; '{print $6}' | sed 's/ //')
monthly_usage=$(vnstat -m --oneline 2>/dev/null | awk -F\; '{print $11}' | sed 's/ //')

clear
echo -e "${BB}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "            ${WB}🧩 Multiport Websocket Autoscript by Rakha 🧩${NC}"
echo -e "${BB}╠════════════════════════════════════════════════════════════╣${NC}"
echo -e "                   ${WB}🖥️  Informasi Server 🖥️${NC}                 "
echo -e "${BB}╠════════════════════════════════════════════════════════════╣${NC}"
echo -e "  ${RB}♦️${NC} ${YB}SISTEM    : $(hostnamectl | grep 'Operating System' | cut -d ' ' -f5-) ${NC}"
echo -e "  ${RB}♦️${NC} ${YB}KERNEL    : $(uname -r) ${NC}"
echo -e "  ${RB}♦️${NC} ${YB}UPTIME    : $uptime ${NC}"
echo -e "  ${RB}♦️${NC} ${YB}CPU       : ${load_cpu:-N/A} ${NC}"
echo -e "  ${RB}♦️${NC} ${YB}RAM       : $uram MB / $tram MB ${NC}"
echo -e "  ${RB}♦️${NC} ${YB}DOMAIN    : $domain ${NC}"
echo -e "  ${RB}♦️${NC} ${YB}IP VPS    : $IPVPS ${NC}"
echo -e "  ${RB}♦️${NC} ${YB}Bandwidth : Daily: ${daily_usage:-N/A} / Monthly: ${monthly_usage:-N/A}${NC}"
echo -e "${BB}╠════════════════════════════════════════════════════════════╣${NC}"
echo -e "                      ${WB}⚙️  Menu XRAYS  ⚙️${NC}"
echo -e "${BB}╠════════════════════════════════════════════════════════════╣${NC}"
echo -e "  ${RB}01.${NC} ${YB}XRAY VMESS WS     ${WB}[${GB}${vmess}${WB}]${NC} 🌀"
echo -e "  ${RB}02.${NC} ${YB}XRAY VLESS WS     ${WB}[${GB}${vless}${WB}]${NC} 📡"
echo -e "  ${RB}03.${NC} ${YB}XRAY TROJAN WS    ${WB}[${GB}${trws}${WB}]${NC} 🛡️"
echo -e "  ${RB}04.${NC} ${YB}XRAY TROJAN XTLS  ${WB}[${GB}${txtls}${WB}]${NC} 🔐"
echo -e "  ${RB}05.${NC} ${YB}XRAY TROJAN TCP   ${WB}[${GB}${tr}${WB}]${NC} 🧰"
echo -e "  ${RB}06.${NC} ${YB}MENU SSH & WEBSOCKET   ${WB}[${GB}${ssh_users}${WB}]${NC} 🔑"
echo -e "  ${RB}07.${NC} ${YB}MENU L2TP / IPSEC      ${WB}[${GB}${l2tp_users}${WB}]${NC} 🌐"
echo -e "${BB}╠════════════════════════════════════════════════════════════╣${NC}"
echo -e "                      ${WB}🛠️  Menu VPS  🛠️${NC}"
echo -e "${BB}╠════════════════════════════════════════════════════════════╣${NC}"
echo -e "  ${RB}08.${NC} ${YB}PASANG PEMBLOKIR IKLAN              🚫"
echo -e "  ${RB}09.${NC} ${YB}PASANG TCP BBRPLUS                  🚀"
echo -e "  ${RB}10.${NC} ${YB}MENU PEMBLOKIR IKLAN                🧹"
echo -e "  ${RB}11.${NC} ${YB}GANTI DNS                           🧬"
echo -e "  ${RB}12.${NC} ${YB}CEK NETFLIX / MEDIA                 🎬"
echo -e "  ${RB}13.${NC} ${YB}BATAS KECEPATAN BANDWIDTH           📶"
echo -e "  ${RB}14.${NC} ${YB}GANTI DOMAIN                        🌐"
echo -e "  ${RB}15.${NC} ${YB}PERPANJANG CERT XRAYS               📜"
echo -e "  ${RB}16.${NC} ${YB}CEK STATUS VPN                      📊"
echo -e "  ${RB}17.${NC} ${YB}CEK PORT VPN                        🔍"
echo -e "  ${RB}18.${NC} ${YB}RESTART LAYANAN VPN                 ♻️"
echo -e "  ${RB}19.${NC} ${YB}UJI JARINGAN (Speedtest)            ⚡"
echo -e "  ${RB}20.${NC} ${YB}CEK CPU & RAM                       🧠"
echo -e "  ${RB}21.${NC} ${YB}CEK PENGGUNAAN BANDWIDTH            📈"
echo -e "  ${RB}22.${NC} ${YB}CADANGKAN DATA                      💾"
echo -e "  ${RB}23.${NC} ${YB}PULIHKAN DATA                       ♻️"
echo -e "  ${RB}24.${NC} ${YB}REBOOT VPS                          🔁"
echo -e "  ${RB}25.${NC} ${YB}MENU XRAY-CORE                      🧪"
echo -e "  ${RB}26.${NC} ${YB}MENU SWAP RAM                       💿"
echo -e "  ${RB}27.${NC} ${YB}BERSIHKAN LOG                       🧽"
echo -e "  ${RB}28.${NC} ${YB}TAMPILKAN INFO SYSTEM (NEOFETCH)    ❌"
echo -e "  ${RB}29.${NC} ${YB}UPDATE SCRIPT DARI GITHUB           📥"
echo -e "${BB}╠════════════════════════════════════════════════════════════╣${NC}"
echo ""
read -p "📌 Pilih Menu [ 1 - 29 ] : " menu

case $menu in
  1)  clear; menu-ws ;;
  2)  clear; menu-vless ;;
  3)  clear; menu-tr ;;
  4)  clear; menu-xrt ;;
  5)  clear; menu-xtr ;;
  6)  clear; menu-ssh ;;
  7)  clear; menu-l2tp ;;
  8)  clear; ins-helium ;;
  9)  clear; bbr ;;
 10)  clear; helium ;;
 11)  clear; dns ;;
 12)  clear; nf ;;
 13)  clear; limit ;;
 14)  clear; add-host ;;
 15)  clear; certxray ;;
 16)  clear; status ;;
 17)  clear; info ;;
 18)  clear; restart ;;
 19)  clear; speedtest ;;
 20)  clear; htop ;;
 21)  clear; vnstat ;;
 22)  clear; backup ;;
 23)  clear; restore ;;
 24)  clear; reboot ;;
 25)  clear; wget -q -O /usr/bin/xraychanger "https://raw.githubusercontent.com/yanzwrt/Xcore-custompath/main/xraychanger.sh" && chmod +x /usr/bin/xraychanger && xraychanger ;;
 26)  clear; wget -q -O /usr/bin/swapram "https://raw.githubusercontent.com/yanzwrt/swapram/main/swapram.sh" && chmod +x /usr/bin/swapram && swapram ;;
 27)  clear; cleaner ;;
 28)  clear; neofetch ;;
 29)  clear; curl -fsSL https://raw.githubusercontent.com/yanzwrt/RPAVPN/main/update.sh -o /root/update.sh && bash /root/update.sh ;;
  *)  clear; menu ;;
esac

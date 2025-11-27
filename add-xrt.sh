#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edisi   : Stable Edition V1.0
# Pembuat : Rakha-VPN (mod RPAVPN by yanzwrt)
# (C) Hak Cipta 2025
# =========================================

# WARNA TERMINAL
NC='\e[0m'
RED='\e[31;1m'
GREEN='\e[32;1m'
YELLOW='\e[33;1m'
BLUE='\e[34;1m'
MAGENTA='\e[35;1m'
CYAN='\e[36;1m'
WHITE='\e[37;1m'

clear
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=$(date +"%Y-%m-%d" -d "$dateFromServer")

# IP & DOMAIN
MYIP=$(curl -sS ifconfig.me)
MYIP2=$(curl -sS ipv4.icanhazip.com)
domain=$(cat /root/domain)

# INPUT USERNAME
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
    clear
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}          ⇱ Buat Akun Trojan TCP XTLS ⇲       ${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    read -rp "❯ Username           : " -e user
    CLIENT_EXISTS=$(grep -w "$user" /usr/local/etc/xray/xtrojan.json | wc -l)

    if [[ ${CLIENT_EXISTS} == '1' ]]; then
        echo -e ""
        echo -e "${RED}⚠️ Username sudah ada, silakan gunakan nama lain!${NC}"
        read -n 1 -s -r -p "Tekan tombol apapun untuk kembali..."
        menu
    fi
done

# BUG / SNI
read -p "➤ Bug Address (cth: www.google.com) : " address
read -p "➤ Bug SNI/Host (cth: m.facebook.com) : " hst
read -p "➤ Masa Aktif (hari) : " masaaktif

# SET KONFIGURASI BUG ADDRESS (wildcard: bug.domain)
bug_addr=${address}.
bug_addr2=${address}
sts=${bug_addr2}
[[ $address != "" ]] && sts=${bug_addr}

# SET KONFIGURASI SNI / HOST
bug=${hst}
bug2=${domain}
sni=${bug2}
[[ $hst != "" ]] && sni=${bug}

hariini=$(date -d "0 days" +"%Y-%m-%d")
exp=$(date -d "$masaaktif days" +"%Y-%m-%d")

# TAMBAH KE KONFIGURASI XRAY (XTLS TROJAN)
sed -i '/#trojan-xtls$/a\### '"$user $exp"'\
},{"password": "'$user'","flow": "xtls-rprx-direct","email": "'$user'"' /usr/local/etc/xray/xtrojan.json

# =========================
#   LINK TROJAN XTLS
# =========================
trojanlink1="trojan://${user}@${sts}${domain}:443?allowInsecure=1&security=xtls&headerType=none&type=tcp&flow=xtls-rprx-direct&sni=${sni}#TROJAN_DIRECT_${user}"
trojanlink2="trojan://${user}@${sts}${domain}:443?allowInsecure=1&security=xtls&headerType=none&type=tcp&flow=xtls-rprx-direct-udp443&sni=${sni}#TROJAN_DIRECTUDP443_${user}"
trojanlink3="trojan://${user}@${sts}${domain}:443?allowInsecure=1&security=xtls&headerType=none&type=tcp&flow=xtls-rprx-splice&sni=${sni}#TROJAN_SPLICE_${user}"
trojanlink4="trojan://${user}@${sts}${domain}:443?allowInsecure=1&security=xtls&headerType=none&type=tcp&flow=xtls-rprx-splice-udp443&sni=${sni}#TROJAN_SPLICEUDP443_${user}"

# RESTART XRAY
systemctl restart xray@xtrojan.service
service cron restart

# =========================
#   YAML CLASH DIRECT
# =========================
cat > /home/vps/public_html/$user-$exp-TRDIRECT.yaml <<EOF
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
    - 112.215.203.254
  default-nameserver:
    - 8.8.8.8
    - 1.1.1.1
    - 112.215.203.254
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
    - time.*.com
    - time.*.gov
    - time.*.edu.cn
    - time.*.apple.com
    - time1.*.com
    - time2.*.com
    - time3.*.com
    - time4.*.com
    - time5.*.com
    - time6.*.com
    - time7.*.com
    - ntp.*.com
    - ntp1.*.com
    - ntp2.*.com
    - ntp3.*.com
    - ntp4.*.com
    - ntp5.*.com
    - ntp6.*.com
    - ntp7.*.com
    - "*.time.edu.cn"
    - "*.ntp.org.cn"
    - +.pool.ntp.org
    - time1.cloud.tencent.com
    - music.163.com
    - "*.music.163.com"
    - "*.126.net"
    - musicapi.taihe.com
    - music.taihe.com
    - songsearch.kugou.com
    - trackercdn.kugou.com
    - "*.kuwo.cn"
    - api-jooxtt.sanook.com
    - api.joox.com
    - joox.com
    - y.qq.com
    - "*.y.qq.com"
    - streamoc.music.tc.qq.com
    - mobileoc.music.tc.qq.com
    - isure.stream.qqmusic.qq.com
    - dl.stream.qqmusic.qq.com
    - aqqmusic.tc.qq.com
    - amobile.music.tc.qq.com
    - "*.xiami.com"
    - "*.music.migu.cn"
    - music.migu.cn
    - "*.msftconnecttest.com"
    - "*.msftncsi.com"
    - msftconnecttest.com
    - msftncsi.com
    - localhost.ptlogin2.qq.com
    - localhost.sec.qq.com
    - +.srv.nintendo.net
    - +.stun.playstation.net
    - xbox.*.microsoft.com
    - xnotify.xboxlive.com
    - +.battlenet.com.cn
    - +.wotgame.cn
    - +.wggames.cn
    - +.wowsgame.cn
    - +.wargaming.net
    - proxy.golang.org
    - stun.*.*
    - stun.*.*.*
    - +.stun.*.*
    - +.stun.*.*.*
    - +.stun.*.*.*.*
    - heartbeat.belkin.com
    - "*.linksys.com"
    - "*.linksyssmartwifi.com"
    - "*.router.asus.com"
    - mesu.apple.com
    - swscan.apple.com
    - swquery.apple.com
    - swdownload.apple.com
    - swcdn.apple.com
    - swdist.apple.com
    - lens.l.google.com
    - stun.l.google.com
    - +.nflxvideo.net
    - "*.square-enix.com"
    - "*.finalfantasyxiv.com"
    - "*.ffxiv.com"
    - "*.mcdn.bilivideo.cn"
    - +.media.dssott.com
proxies:
  - name: XRAY_TROJAN_DIRECT_${user}
    server: ${sts}${domain}
    port: 443
    type: trojan
    password: ${user}
    flow: xtls-rprx-direct
    skip-cert-verify: true
    sni: ${sni}
    udp: true
proxy-groups:
  - name: RakhaVPN-AUTOSCRIPT
    type: select
    proxies:
      - XRAY_TROJAN_DIRECT_${user}
      - DIRECT
rules:
  - MATCH,RakhaVPN-AUTOSCRIPT
EOF

# =========================
#   YAML CLASH SPLICE
# =========================
cat > /home/vps/public_html/$user-$exp-TRSPLICE.yaml <<EOF
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
    - 112.215.203.254
  default-nameserver:
    - 8.8.8.8
    - 1.1.1.1
    - 112.215.203.254
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
    - time.*.com
    - time.*.gov
    - time.*.edu.cn
    - time.*.apple.com
    - time1.*.com
    - time2.*.com
    - time3.*.com
    - time4.*.com
    - time5.*.com
    - time6.*.com
    - time7.*.com
    - ntp.*.com
    - ntp1.*.com
    - ntp2.*.com
    - ntp3.*.com
    - ntp4.*.com
    - ntp5.*.com
    - ntp6.*.com
    - ntp7.*.com
    - "*.time.edu.cn"
    - "*.ntp.org.cn"
    - +.pool.ntp.org
    - time1.cloud.tencent.com
    - music.163.com
    - "*.music.163.com"
    - "*.126.net"
    - musicapi.taihe.com
    - music.taihe.com
    - songsearch.kugou.com
    - trackercdn.kugou.com
    - "*.kuwo.cn"
    - api-jooxtt.sanook.com
    - api.joox.com
    - joox.com
    - y.qq.com
    - "*.y.qq.com"
    - streamoc.music.tc.qq.com
    - mobileoc.music.tc.qq.com
    - isure.stream.qqmusic.qq.com
    - dl.stream.qqmusic.qq.com
    - aqqmusic.tc.qq.com
    - amobile.music.tc.qq.com
    - "*.xiami.com"
    - "*.music.migu.cn"
    - music.migu.cn
    - "*.msftconnecttest.com"
    - "*.msftncsi.com"
    - msftconnecttest.com
    - msftncsi.com
    - localhost.ptlogin2.qq.com
    - localhost.sec.qq.com
    - +.srv.nintendo.net
    - +.stun.playstation.net
    - xbox.*.microsoft.com
    - xnotify.xboxlive.com
    - +.battlenet.com.cn
    - +.wotgame.cn
    - +.wggames.cn
    - +.wowsgame.cn
    - +.wargaming.net
    - proxy.golang.org
    - stun.*.*
    - stun.*.*.*
    - +.stun.*.*
    - +.stun.*.*.*
    - +.stun.*.*.*.*
    - heartbeat.belkin.com
    - "*.linksys.com"
    - "*.linksyssmartwifi.com"
    - "*.router.asus.com"
    - mesu.apple.com
    - swscan.apple.com
    - swquery.apple.com
    - swdownload.apple.com
    - swcdn.apple.com
    - swdist.apple.com
    - lens.l.google.com
    - stun.l.google.com
    - +.nflxvideo.net
    - "*.square-enix.com"
    - "*.finalfantasyxiv.com"
    - "*.ffxiv.com"
    - "*.mcdn.bilivideo.cn"
    - +.media.dssott.com
proxies:
  - name: XRAY_TROJAN_SPLICE_${user}
    server: ${sts}${domain}
    port: 443
    type: trojan
    password: ${user}
    flow: xtls-rprx-splice
    skip-cert-verify: true
    sni: ${sni}
    udp: true
proxy-groups:
  - name: RakhaVPN-AUTOSCRIPT
    type: select
    proxies:
      - XRAY_TROJAN_SPLICE_${user}
      - DIRECT
rules:
  - MATCH,RakhaVPN-AUTOSCRIPT
EOF

# OUTPUT
clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}         ⇱ XRAY | Trojan TCP XTLS ⇲           ${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📌 Informasi Akun:${NC}"
echo -e " 🟢 Username           : ${user}"
echo -e " 🟢 Domain             : ${domain}"
echo -e " 🟢 IP VPS             : ${MYIP}"
echo -e " 🟢 Wildcard           : ${address}.${domain}"
echo -e " 🟢 Port               : 443"
echo -e " 🟢 SNI / Host         : ${sni}"
echo -e " 🟢 Alamat Bug         : ${sts}${domain}"
echo -e " 🟢 Network            : TCP"
echo -e " 🟢 Security           : XTLS"
echo -e " 🟢 Flow               : Direct & Splice"
echo -e " 🟢 Allow Insecure     : true"
echo -e " 🟢 Dibuat Tanggal     : $hariini"
echo -e " 🟢 Expired Tanggal    : $exp"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🔗 Link Trojan:${NC}"
echo -e " 📎 Direct             : ${trojanlink1}"
echo -e " 📎 Direct UDP 443     : ${trojanlink2}"
echo -e " 📎 Splice             : ${trojanlink3}"
echo -e " 📎 Splice UDP 443     : ${trojanlink4}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}📥 File YAML Clash:${NC}"
echo -e " 📄 Direct             : http://${MYIP2}:81/$user-$exp-TRDIRECT.yaml"
echo -e " 📄 Splice             : http://${MYIP2}:81/$user-$exp-TRSPLICE.yaml"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "✅ ${WHITE}Script by Rakha-VPN x RPAVPN${NC}"
echo ""
read -p "$(echo -e "Tekan ${YELLOW}[ ENTER ]${NC} untuk kembali ke menu...") "
menu

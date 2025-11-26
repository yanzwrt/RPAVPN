#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edisi   : Stable Edition V1.0
# Pembuat : RakhaVPN
# (C) Hak Cipta 2025
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

# IP & Domain
MYIP=$(curl -sS ifconfig.me)
domain=$(cat /root/domain)
MYIP2=$(curl -sS ipv4.icanhazip.com)

# FORM INPUT USER
clear
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${user_EXISTS} == '0' ]]; do
    echo -e "${BB}════════════════════════════════════════════════${NC}"
    echo -e "${WB}         Tambah Akun XRAY TROJAN WS            ${NC}"
    echo -e "${BB}════════════════════════════════════════════════${NC}"
    read -rp "➤ Masukkan Nama Pengguna : " -e user
    user_EXISTS=$(grep -w $user /usr/local/etc/xray/trojanws.json | wc -l)
    if [[ ${user_EXISTS} == '1' ]]; then
        echo -e "${RB}⚠️  Nama pengguna sudah terdaftar. Silakan gunakan nama lain.${NC}"
        read -n 1 -s -r -p "$(echo -e "${YB}Tekan tombol apa saja untuk kembali ke menu${NC}")"
        menu
    fi
done

read -p "➤ Bug Address (cth: www.google.com) : " address
read -p "➤ Bug SNI/Host (cth: m.facebook.com) : " hst
read -p "➤ Masa Aktif (hari) : " masaaktif

# SET KONFIGURASI
bug_addr=${address}.
bug_addr2=${address}
sts=${bug_addr2}
[[ $address != "" ]] && sts=${bug_addr}

bug=${hst}
bug2=${domain}
sni=${bug2}
[[ $hst != "" ]] && sni=${bug}

exp=$(date -d "$masaaktif days" +"%Y-%m-%d")
hariini=$(date +"%Y-%m-%d")

# TAMBAH KE KONFIGURASI XRAY
sed -i '/#tr$/a\### '"$user $exp"'\n},{"password": "'$user'","email": "'$user'"' /usr/local/etc/xray/trojanws.json
sed -i '/#trnone$/a\### '"$user $exp"'\n},{"password": "'$user'","email": "'$user'"' /usr/local/etc/xray/trnone.json

# RESTART XRAY
systemctl restart xray@trojanws.service
systemctl restart xray@trnone.service
service cron restart

# LINK TROJAN WS
trojanlink1="trojan://${user}@${sts}${domain}:443?type=ws&security=tls&host=${domain}&path=/trojan&sni=${sni}#XRAY_TROJAN_TLS_${user}"
trojanlink2="trojan://${user}@${sts}${domain}:80?type=ws&security=none&host=${domain}&path=/trojan#XRAY_TROJAN_NTLS_${user}"

# YAML
cat > /home/vps/public_html/$user-$exp-TRTLS.yaml <<EOF
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
  - name: XRAY_TROJAN_TLS_${user}
    server: ${sts}${domain}
    port: 443
    type: trojan
    password: ${user}
    skip-cert-verify: true
    sni: ${sni}
    network: ws
    ws-opts:
      path: /trojan
      headers:
        Host: ${domain}
    udp: true
proxy-groups:
  - name: RakhaVPN-Autoscript
    type: select
    proxies:
      - XRAY_TROJAN_TLS_${user}
      - DIRECT
rules:
  - MATCH,rakhaVPN-Autoscript
$(cat /home/vps/public_html/$user-$exp-TRTLS.yaml)
EOF
# OUTPUT
clear
echo -e "${BB}════════════════════════════════════════════════${NC}"
echo -e "${WB}            Detail Akun XRAY TROJAN WS          ${NC}"
echo -e "${BB}════════════════════════════════════════════════${NC}"
echo -e "📌 Username         : ${user}"
echo -e "🌐 Domain           : ${domain}"
echo -e "🔐 IP/Host          : ${MYIP}"
echo -e "🔒 Port TLS         : 443"
echo -e "🔓 Port Non-TLS     : 80, 8080, 8880"
echo -e "🔑 Password         : ${user}"
echo -e "🔒 Security         : TLS"
echo -e "🔁 Network          : WS"
echo -e "📄 Path TLS         : /trojan"
echo -e "📄 Path Non-TLS     : /trojan"
echo -e "📆 Tanggal Dibuat   : ${hariini}"
echo -e "⏳ Berakhir Pada    : ${exp}"
echo -e "${BB}════════════════════════════════════════════════${NC}"
echo -e "🔗 Link TLS         : ${trojanlink1}"
echo -e "${BB}════════════════════════════════════════════════${NC}"
echo -e "🔗 Link Non-TLS     : ${trojanlink2}"
echo -e "${BB}════════════════════════════════════════════════${NC}"
echo -e "📄 YAML TLS         : http://${MYIP2}:81/$user-TRTLS.yaml"
echo -e "${BB}════════════════════════════════════════════════${NC}"
echo -e "✨ Script by: RakhaVPN"
echo ""
read -p "$(echo -e "${YB}Tekan Enter untuk kembali ke menu ...${NC}")"
menu

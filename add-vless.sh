#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edisi   : Stable Edition V1.0
# Pembuat : Rakha-VPN
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

MYIP=$(curl -sS ifconfig.me)
domain=$(cat /root/domain)
MYIP2=$(curl -sS ipv4.icanhazip.com)

# FORM INPUT USER
clear
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
    echo -e "${BB}════════════════════════════════════════════════${NC}"
    echo -e "${WB}         Tambah Akun XRAY VLESS WS             ${NC}"
    echo -e "${BB}════════════════════════════════════════════════${NC}"
    
    read -rp "➤ Masukkan Nama Pengguna : " -e user
    CLIENT_EXISTS=$(grep -w $user /usr/local/etc/xray/vless.json | wc -l)

    if [[ ${CLIENT_EXISTS} == '1' ]]; then
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

uuid=$user
exp=$(date -d "$masaaktif days" +"%Y-%m-%d")
hariini=$(date +"%Y-%m-%d")

# TAMBAH KE KONFIGURASI XRAY
sed -i '/#tls$/a\### '"$user $exp"'\
},{"id": "'$uuid'","email": "'$user'"' /usr/local/etc/xray/vless.json
sed -i '/#none$/a\### '"$user $exp"'\
},{"id": "'$uuid'","email": "'$user'"' /usr/local/etc/xray/vnone.json

# RESTART XRAY
systemctl restart xray@vless.service
systemctl restart xray@vnone.service
service cron restart

# LINK
vlesslink1="vless://${uuid}@${sts}${domain}:443?type=ws&encryption=none&security=tls&host=${domain}&path=/vless&allowInsecure=1&sni=${sni}#XRAY_VLESS_TLS_${user}"
vlesslink2="vless://${uuid}@${sts}${domain}:80?type=ws&encryption=none&security=none&host=${domain}&path=/vless#XRAY_VLESS_NTLS_${user}"

cat > /home/vps/public_html/$user-$exp-VLESSTLS.yaml <<EOF
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
  - name: XRAY_VLESS_TLS_${user}
    server: ${sts}${domain}
    port: 443
    type: vless
    uuid: ${user}
    cipher: auto
    tls: true
    skip-cert-verify: true
    servername: ${sni}
    network: ws
    ws-opts:
      path: /vless
      headers:
        Host: ${domain}
    udp: true
proxy-groups:
  - name: RakhaVPN-Autoscript
    type: select
    proxies:
      - XRAY_VLESS_TLS_${user}
      - DIRECT
rules:
  - MATCH,RakhaVPN-Autoscript
EOF

cat > /home/vps/public_html/$user-$exp-VLESSNTLS.yaml <<EOF
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
  - name: XRAY_VLESS_NTLS_${user}
    server: ${sts}${domain}
    port: 80
    type: vless
    uuid: ${user}
    cipher: auto
    tls: false
    skip-cert-verify: true
    servername: ${sni}
    network: ws
    ws-opts:
      path: /vless
      headers:
        Host: ${domain}
    udp: true
proxy-groups:
  - name: RakhaVPN-Autoscript
    type: select
    proxies:
      - XRAY_VLESS_NTLS_${user}
      - DIRECT
rules:
  - MATCH,rakhaVPN-Autoscript
EOF

# OUTPUT
clear
echo -e "${BB}════════════════════════════════════════════════${NC}"
echo -e "${WB}             Detail Akun XRAY VLESS WS          ${NC}"
echo -e "${BB}════════════════════════════════════════════════${NC}"
echo -e "📌 Username         : ${user}"
echo -e "🌐 Domain           : ${domain}"
echo -e "🔐 IP/Host          : ${MYIP}"
echo -e "🔒 Port TLS         : 443"
echo -e "🔓 Port Non-TLS     : 80, 8080, 8880"
echo -e "🆔 UUID             : ${uuid}"
echo -e "🔒 Security         : TLS"
echo -e "🔁 Network          : WS"
echo -e "📄 Path TLS         : /vless"
echo -e "📄 Path Non-TLS     : /vless"
echo -e "🧩 Multipath        : /yourpath"
echo -e "📆 Tanggal Dibuat   : ${hariini}"
echo -e "⏳ Berakhir Pada    : ${exp}"
echo -e "${BB}════════════════════════════════════════════════${NC}"
echo -e "🔗 Link TLS         : ${vlesslink1}"
echo -e "${BB}════════════════════════════════════════════════${NC}"
echo -e "🔗 Link Non-TLS     : ${vlesslink2}"
echo -e "${BB}════════════════════════════════════════════════${NC}"
echo -e "📄 YAML TLS         : http://${MYIP2}:81/$user-VLESSTLS.yaml"
echo -e "📄 YAML Non-TLS     : http://${MYIP2}:81/$user-VLESSNTLS.yaml"
echo -e "${BB}════════════════════════════════════════════════${NC}"
echo -e "✨ Script by: Rakha-VPN"
echo ""
read -p "$(echo -e "${YB}Tekan Enter untuk kembali ke menu ...${NC}")"
menu

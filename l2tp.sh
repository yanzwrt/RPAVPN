#!/bin/bash
# L2TP/IPsec installer for RPAVPN
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# Default values
L2TP_USER=${L2TP_USER:-l2tpuser}
L2TP_PASSWORD=${L2TP_PASSWORD:-$(openssl rand -base64 12)}
IPSEC_PSK=${IPSEC_PSK:-$(openssl rand -hex 16)}
DOMAIN_FILE="/root/domain"
SERVER_IP=${SERVER_IP:-$(curl -sS ipv4.icanhazip.com || hostname -I | awk '{print $1}')}
SERVER_ID=${SERVER_ID:-$(cat "$DOMAIN_FILE" 2>/dev/null || echo "$SERVER_IP")}

apt-get update -y
apt-get install -y strongswan xl2tpd ppp lsof fail2ban

cat > /etc/ipsec.conf <<IPSEC
config setup
  uniqueids=never

conn L2TP-PSK
  keyexchange=ikev1
  authby=secret
  type=transport
  left=%defaultroute
  leftid=$SERVER_ID
  leftprotoport=17/1701
  right=%any
  rightprotoport=17/%any
  auto=add
IPSEC

cat > /etc/ipsec.secrets <<SECRETS
$SERVER_ID %any : PSK "$IPSEC_PSK"
SECRETS
chmod 600 /etc/ipsec.secrets

cat > /etc/xl2tpd/xl2tpd.conf <<XL2TPD
[global]
ipsec saref = yes
[lns default]
ip range = 10.10.10.2-10.10.10.254
local ip = 10.10.10.1
require chap = yes
refuse pap = yes
require authentication = yes
ppp debug = yes
pppoptfile = /etc/ppp/options.xl2tpd
length bit = yes
XL2TPD

cat > /etc/ppp/options.xl2tpd <<PPP
require-mschap-v2
ms-dns 1.1.1.1
ms-dns 8.8.8.8
asyncmap 0
hide-password
ipcp-accept-local
ipcp-accept-remote
noccp
idle 1800
mtu 1410
mru 1410
nodefaultroute
proxyarp
lcp-echo-failure 4
lcp-echo-interval 30
PPP

echo "$L2TP_USER l2tp-server \"$L2TP_PASSWORD\" *" > /etc/ppp/chap-secrets
chmod 600 /etc/ppp/chap-secrets

PUBLIC_IFACE=${PUBLIC_IFACE:-$(ip route get 1.1.1.1 | awk '{print $5; exit}')}
if [ -z "$PUBLIC_IFACE" ]; then
  echo "Gagal menemukan interface publik" >&2
  exit 1
fi

iptables -I INPUT -p udp --dport 500 -j ACCEPT
iptables -I INPUT -p udp --dport 4500 -j ACCEPT
iptables -I INPUT -p udp --dport 1701 -j ACCEPT
iptables -t nat -I POSTROUTING -s 10.10.10.0/24 -o "$PUBLIC_IFACE" -j MASQUERADE

sysctl -w net.ipv4.ip_forward=1 >/dev/null
if ! grep -q '^net.ipv4.ip_forward=1' /etc/sysctl.conf; then
  echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
fi

systemctl enable strongswan --now
systemctl enable xl2tpd --now

cat <<INFO
L2TP/IPsec sudah diaktifkan.
 • Host/ID Server : $SERVER_ID
 • PSK            : $IPSEC_PSK
 • User           : $L2TP_USER
 • Password       : $L2TP_PASSWORD
INFO

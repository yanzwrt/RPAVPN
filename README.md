<!-- BANNER -->
<p align="center">
  <img src="https://img.shields.io/badge/RakhaVPN-XRAY%20Multiprotocol-blue?style=for-the-badge&logo=cloudflare&logoColor=white">
</p>

<h1 align="center">🚀 XRAY Multiport Websocket Autoscript</h1>
<h3 align="center">⚡ Support WS • SNI • CustomPath • SSH Websocket • L2TP • XTLS • Trojan • IPv6 Mode ⚡</h3>

<p align="center">
  <img src="https://img.shields.io/github/v/release/yanzwrt/RPAVPN?style=for-the-badge&color=green">
  <img src="https://img.shields.io/github/last-commit/yanzwrt/RPAVPN?style=for-the-badge&logo=github&color=purple">
  <img src="https://img.shields.io/badge/Maintained-YES-blue?style=for-the-badge">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Debian-10/11/12-red?style=for-the-badge&logo=debian">
  <img src="https://img.shields.io/badge/Ubuntu-18.04/20.04-orange?style=for-the-badge&logo=ubuntu">
</p>

---

# ⚠️ WAJIB DIPERHATIKAN SEBELUM INSTALL

Jika memakai **Cloudflare CDN**, WAJIB atur:

| Pengaturan | Status |
|-----------|--------|
| SSL/TLS Mode | **Full** |
| Universal SSL | **ON** |
| Always Use HTTPS | **OFF** |
| TLS Recommender | **ON** |
| Edge Certificates | Aktif |

Mendukung:
✔ Bug Host / SNI  
✔ Wildcard Domain  
✔ Cloudflare Proxy / DNS Only  
✔ CDN Mode  

---

# 🧰 FITUR AUTOSCRIPT LENGKAP

### 🟦 XRAY Services
| Layanan | TLS | NTLS | WS | TCP | XTLS | Custom Path | SNI |
|--------|:---:|:----:|:--:|:---:|:---:|:------------:|:---:|
| VMESS | ✔ | ✔ | ✔ | – | – | ✔ | ✔ |
| VLESS | ✔ | ✔ | ✔ | – | – | ✔ | ✔ |
| TROJAN WS | ✔ | ✔ | ✔ | – | – | ✔ | ✔ |
| TROJAN TCP | ✔ | – | – | ✔ | – | – | ✔ |
| TROJAN XTLS | ✔ | – | – | ✔ | ✔ | – | ✔ |

---

### 🟩 SSH & VPN Services  
*(Full Version Only — setup.sh)*

| Service | Status |
|--------|--------|
| SSH Websocket (Dropbear + OpenSSH) | ✔ |
| Stunnel5 TLS | ✔ |
| SSH WS 80 / 443 | ✔ |
| L2TP/IPsec (PSK + UserPass) | ✔ |

---

### 🟨 Fitur Tambahan
✔ YAML generator  
✔ Auto delete expired account (xp.sh)  
✔ Auto reboot 03.00 WIB  
✔ Auto backup & restore  
✔ Auto clear log  
✔ XRAY core changer  
✔ Multipath support  
✔ BBRplus Optimizer  
✔ Limit speed user  
✔ DNS changer  
✔ Media checker (Netflix / Disney+ / dll)  
✔ CPU & RAM Monitor  
✔ Speedtest CLI  
✔ VNStat Bandwidth Monitor  
✔ Ads blocker support  
✔ Swap RAM Manager  

---

# 📦 INSTALASI SCRIPT

## 🅰️ FULL VERSION (Rekomendasi) — IPv6 OFF  
Termasuk SSH WS + L2TP + XRAY lengkap.

```bash
sysctl -w net.ipv6.conf.all.disable_ipv6=1 \
&& sysctl -w net.ipv6.conf.default.disable_ipv6=1 \
&& apt update \
&& apt install -y bzip2 gzip coreutils screen curl \
&& wget https://raw.githubusercontent.com/yanzwrt/RPAVPN/main/setup.sh \
&& chmod +x setup.sh \
&& ./setup.sh

## 🅱️ LITE VERSION — IPv6 ON
Versi ringan, hanya XRAY (Support WS + SNI).
Tidak ada SSH & tidak ada L2TP.

```bash
apt update \
&& apt install -y bzip2 gzip coreutils screen curl \
&& wget https://raw.githubusercontent.com/yanzwrt/RPAVPN/main/setup2.sh \
&& chmod +x setup2.sh \
&& ./setup2.sh

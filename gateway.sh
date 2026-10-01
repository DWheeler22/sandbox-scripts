#!/bin/bash
# Toggle Kali between "gateway mode" (eth0 WAN + eth1 analysis) and normal single-NIC mode.
# Usage: sudo gateway on|off|status
set -uo pipefail

WAN=eth0
LAN=eth1
PROFILE=analysis
SYSCTL=/etc/sysctl.d/99-gateway.conf

[ "$EUID" -eq 0 ] || { echo "Run with sudo."; exit 1; }

status() {
  echo "ip_forward : $(cat /proc/sys/net/ipv4/ip_forward)"
  echo -n "nft filter : "; nft list table inet filter >/dev/null 2>&1 && echo loaded || echo not loaded
  echo -n "nft nat    : "; nft list table ip nat >/dev/null 2>&1 && echo loaded || echo not loaded
  echo "dnsmasq    : $(systemctl is-active dnsmasq)"
  echo "nftables   : $(systemctl is-active nftables)"
  echo; ip -br a show "$WAN" "$LAN" 2>/dev/null
}

on() {
  echo "[*] Enabling gateway mode"

  # 1. Firewall first, so forwarding is never enabled without rules
  nft -c -f /etc/nftables.conf || { echo "nftables.conf has errors, aborting."; exit 1; }
  systemctl enable nftables >/dev/null 2>&1
  systemctl restart nftables
  nft list table inet filter >/dev/null 2>&1 || { echo "Firewall failed to load, aborting."; exit 1; }

  # 2. Analysis interface
  nmcli con modify "$PROFILE" connection.autoconnect yes
  nmcli con up "$PROFILE"

  # 3. DHCP/DNS for the guest
  systemctl enable dnsmasq >/dev/null 2>&1
  systemctl restart dnsmasq

  # 4. Forwarding last, persistent
  echo 'net.ipv4.ip_forward=1' > "$SYSCTL"
  sysctl -q -w net.ipv4.ip_forward=1

  echo "[+] Gateway mode ON"; echo; status
}

off() {
  echo "[*] Disabling gateway mode"

  # 1. Stop forwarding first
  rm -f "$SYSCTL"
  sysctl -q -w net.ipv4.ip_forward=0

  # 2. Stop DHCP/DNS for the guest
  systemctl disable --now dnsmasq >/dev/null 2>&1

  # 3. Remove firewall rules (stock Kali has none)
  systemctl disable --now nftables >/dev/null 2>&1
  nft flush ruleset

  # 4. Take down the analysis interface and stop it autoconnecting
  nmcli con modify "$PROFILE" connection.autoconnect no
  nmcli con down "$PROFILE" 2>/dev/null

  echo "[+] Gateway mode OFF (Kali is back to normal, eth0 only)"; echo; status
  echo
  echo "Note: Docker is still disabled. Re-enable with: sudo systemctl enable --now docker"
}

case "${1:-}" in
  on) on ;;
  off) off ;;
  status) status ;;
  *) echo "Usage: sudo gateway on|off|status"; exit 1 ;;
esac
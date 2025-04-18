#!/bin/bash

# Interfaces de rede
INTERNET_IFACE="eth0"
LAN_IFACE="eth1"
LAN_SUBNET="192.168.0.0/24"

# Resetando regras
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X

# Politicas padrão
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Habilita roteamento
echo 1 > /proc/sys/net/ipv4/ip_forward

# NAT para compartilhamento de internet
iptables -t nat -A POSTROUTING -o $INTERNET_IFACE -j MASQUERADE
iptables -A FORWARD -i $LAN_IFACE -o $INTERNET_IFACE -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i $INTERNET_IFACE -o $LAN_IFACE -j ACCEPT

# Libera localhost e LAN
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -i $LAN_IFACE -s $LAN_SUBNET -j ACCEPT

# Bloqueio de IPs externos
if [ -f rules/blacklist.txt ]; then
  for ip in $(cat rules/blacklist.txt); do
    iptables -A INPUT -s $ip -j DROP
  done
fi

# Bloqueio de DNS externo (exceto IPs permitidos)
iptables -A OUTPUT -p udp --dport 53 -j DROP
if [ -f rules/dns_allowed.txt ]; then
  for ip in $(cat rules/dns_allowed.txt); do
    iptables -I OUTPUT -d $ip -p udp --dport 53 -j ACCEPT
  done
fi

# Redirecionamento de portas
if [ -f rules/port_forwarding.txt ]; then
  while read line; do
    EXT_PORT=$(echo $line | cut -d':' -f1)
    DEST_IP=$(echo $line | cut -d':' -f2)
    DEST_PORT=$(echo $line | cut -d':' -f3)
    iptables -t nat -A PREROUTING -p tcp --dport $EXT_PORT -j DNAT --to-destination $DEST_IP:$DEST_PORT
    iptables -A FORWARD -p tcp -d $DEST_IP --dport $DEST_PORT -j ACCEPT
  done < rules/port_forwarding.txt
fi

echo "Firewall carregado com sucesso."
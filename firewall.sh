#!/bin/bash

### FIREWALL IPTABLES AVANÇADO
### Ambiente: Servidor com 2 interfaces de rede (ex: eth0 = internet, eth1 = rede interna)

# Defina as interfaces de rede
IF_EXT="eth0"   # Interface externa (Internet)
IF_INT="eth1"   # Interface interna (LAN)

# IP da rede interna
REDE_INT="192.168.0.0/24"

# Flush nas regras atuais
iptables -F
iptables -X
iptables -t nat -F
iptables -t mangle -F

# Política padrão
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Libera loopback
iptables -A INPUT -i lo -j ACCEPT

# Libera conexões já estabelecidas e relacionadas
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# Libera acesso SSH (ajuste a porta conforme necessário)
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# NAT - Compartilhamento de Internet
iptables -t nat -A POSTROUTING -s "$REDE_INT" -o "$IF_EXT" -j MASQUERADE
iptables -A FORWARD -i "$IF_INT" -o "$IF_EXT" -s "$REDE_INT" -j ACCEPT
iptables -A FORWARD -i "$IF_EXT" -o "$IF_INT" -d "$REDE_INT" -m state --state ESTABLISHED,RELATED -j ACCEPT

# BLOQUEIO DE SITES EXTERNOS (exemplos)
# Bloqueia facebook
iptables -A FORWARD -p tcp -d facebook.com -j REJECT
iptables -A FORWARD -p tcp -d www.facebook.com -j REJECT
# Bloqueia TikTok (via IP ou range conhecido)
iptables -A FORWARD -p tcp -d 161.117.57.0/24 -j REJECT

# BLOQUEIO DE IPs EXTERNOS MALICIOSOS
iptables -A INPUT -s 45.134.20.0/24 -j DROP   # Exemplo de IP malicioso
iptables -A INPUT -s 185.234.219.0/24 -j DROP

# REDIRECIONAMENTO DE PORTAS
# Exemplo: redireciona porta 80 do firewall para servidor interno 192.168.0.10 porta 80
iptables -t nat -A PREROUTING -i "$IF_EXT" -p tcp --dport 80 -j DNAT --to-destination 192.168.0.10:80
iptables -A FORWARD -p tcp -d 192.168.0.10 --dport 80 -j ACCEPT

# BLOQUEIO DE DNS EXTERNO
iptables -A FORWARD -p udp --dport 53 -j REJECT
iptables -A FORWARD -p tcp --dport 53 -j REJECT

# EXCEÇÕES AO BLOQUEIO DE DNS PARA IPs INTERNOS ESPECÍFICOS
iptables -A FORWARD -s 192.168.0.2 -p udp --dport 53 -j ACCEPT   # Libera para IP específico
iptables -A FORWARD -s 192.168.0.3 -p tcp --dport 53 -j ACCEPT

# PRIORIZAÇÃO DE TRÁFEGO (QOS SIMPLES COM MARK)
# Marcar pacotes HTTP/HTTPS/FTP/IMAP da diretoria para tratamento especial
# Lista de IPs da diretoria:
IP_DIRETORIA="192.168.0.2 192.168.0.3"

for ip in $IP_DIRETORIA; do
  iptables -t mangle -A PREROUTING -s $ip -p tcp --dport 80 -j MARK --set-mark 10  # HTTP
  iptables -t mangle -A PREROUTING -s $ip -p tcp --dport 443 -j MARK --set-mark 10 # HTTPS
  iptables -t mangle -A PREROUTING -s $ip -p tcp --dport 21 -j MARK --set-mark 10  # FTP
  iptables -t mangle -A PREROUTING -s $ip -p tcp --dport 143 -j MARK --set-mark 10 # IMAP
  iptables -t mangle -A PREROUTING -s $ip -p tcp --dport 993 -j MARK --set-mark 10 # IMAPS
  iptables -t mangle -A PREROUTING -s $ip -p tcp --dport 587 -j MARK --set-mark 10 # SMTP Auth

done

# Aqui você pode integrar com tc/qdisc se desejar priorização real via traffic control

# LOG de pacotes descartados (opcional)
iptables -A INPUT -j LOG --log-prefix "[IPTABLES DROP INPUT] " --log-level 4
iptables -A FORWARD -j LOG --log-prefix "[IPTABLES DROP FORWARD] " --log-level 4

# Fim
clear
echo "Firewall aplicado com sucesso."
iptables -L -v -n

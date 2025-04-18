# 🔥 iptables-firewall-2nics

Firewall completo com `iptables` para servidores com **duas interfaces de rede**.

## Funcionalidades
- ✅ Compartilhamento de internet (NAT/Masquerade)
- 🚫 Bloqueio de IPs indesejados
- 🔁 Redirecionamento de tráfego (port forwarding)
- ⚖️ Balanceamento de carga entre links
- 🎯 Prioridade para tráfego (QoS básico)
- ⛔ Bloqueio de DNS externo (com exceções)

## Requisitos
```bash
sudo apt update && sudo apt install -y iptables iproute2 iptables-persistent
```

## Uso
```bash
sudo bash firewall.sh
```

## Tornar permanente
```bash
sudo iptables-save > /etc/iptables/rules.v4
```
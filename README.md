# 🚀 Linux Firewall Avançado com IPTables

Este projeto traz um **script completo de firewall** baseado em `iptables`, ideal para servidores Linux com duas interfaces de rede (ex: `eth0` para internet e `eth1` para rede interna).

## 📦 Recursos implementados

✅ Compartilhamento de internet (NAT/Masquerade)  
🚫 Bloqueio de IPs e domínios indesejados  
🔁 Redirecionamento de portas (ex: Porta 80 para servidor interno)  
📊 Priorização de tráfego (QoS básico para diretoria)  
🔄 Load balancing entre dois gateways  
🔒 Bloqueio de DNS externo, com exceções para IPs autorizados  

---

## 🧱 Estrutura

```
firewall/
├── firewall.sh         # Script principal do firewall
├── ips_bloqueados.txt  # Lista de IPs externos a bloquear
├── sites_bloqueados.txt# Lista de domínios a bloquear
├── ips_prioritarios.txt# IPs internos com tráfego priorizado
└── README.md           # Este arquivo :)
```

---

## 🚀 Como usar

### 1. 🧪 Teste o script manualmente

```bash
chmod +x firewall.sh
sudo ./firewall.sh
```

### 2. 🔁 Configure para subir com o sistema

Edite o `rc.local`, `systemd` ou seu gerenciador de rede favorito para incluir o script no boot.

---

## ⚙️ Personalize!

- Adicione IPs a serem bloqueados no `ips_bloqueados.txt`
- Adicione sites a serem bloqueados no `sites_bloqueados.txt` (ex: `facebook.com`)
- Defina IPs da diretoria em `ips_prioritarios.txt` para garantir melhor desempenho

---

## 💡 Exemplo de redirecionamento de porta

```bash
# Redirecionar porta 80 da internet para o servidor interno 192.168.0.100
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination 192.168.0.100:80
```

---

## 🧠 Dica de segurança

Este script é um ponto de partida. Para ambientes críticos, revise todas as regras de entrada e mantenha logs ativos!

---

## 🤝 Contribua

Sinta-se livre para clonar, melhorar e enviar um pull request!

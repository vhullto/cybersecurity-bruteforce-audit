#!/bin/bash
# Exemplo educacional: hardening básico de SSH com UFW + Fail2Ban (Ubuntu/Debian)
# Execute somente em ambiente autorizado.

set -e

echo "[+] Permitindo SSH e habilitando firewall (UFW)..."
sudo ufw allow OpenSSH
sudo ufw --force enable

echo "[+] Instalando Fail2Ban (se necessário)..."
sudo apt-get update -y
sudo apt-get install -y fail2ban

echo "[+] Aplicando configuração de proteção para SSH..."
sudo tee /etc/fail2ban/jail.d/ssh-hardening.local > /dev/null <<'EOF'
[sshd]
enabled  = true
port     = ssh
filter   = sshd
logpath  = /var/log/auth.log
maxretry = 3
findtime = 10m
bantime  = 1h
EOF

echo "[+] Reiniciando e validando Fail2Ban..."
sudo systemctl restart fail2ban
sudo systemctl enable fail2ban
sudo fail2ban-client status sshd

echo "[OK] Hardening básico aplicado. Revise thresholds conforme seu ambiente."
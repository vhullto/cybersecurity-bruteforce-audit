#!/bin/bash
# hardening_demo.sh
# Demonstração educacional de hardening SSH em ambiente Linux (Debian/Ubuntu).
# Uso restrito a laboratório autorizado.

set -euo pipefail

SSHD_CONFIG="/etc/ssh/sshd_config"
BACKUP_SUFFIX="$(date +%Y%m%d_%H%M%S)"

if [[ $EUID -ne 0 ]]; then
  echo "[ERRO] Execute como root (ou via sudo)."
  exit 1
fi

echo "[1/5] Criando backup do sshd_config..."
cp "$SSHD_CONFIG" "${SSHD_CONFIG}.bak_${BACKUP_SUFFIX}"

# Função auxiliar para atualizar ou inserir diretiva no sshd_config
set_sshd_option() {
  local key="$1"
  local value="$2"

  if grep -qiE "^\s*${key}\b" "$SSHD_CONFIG"; then
    sed -i -E "s|^\s*${key}\b.*|${key} ${value}|I" "$SSHD_CONFIG"
  else
    echo "${key} ${value}" >> "$SSHD_CONFIG"
  fi
}

echo "[2/5] Aplicando políticas mínimas de hardening SSH..."
# Impede login direto de root
set_sshd_option "PermitRootLogin" "no"
# Limita tentativas de autenticação por sessão
set_sshd_option "MaxAuthTries" "3"
# Reduz janela de tempo para autenticação
set_sshd_option "LoginGraceTime" "30"
# Opcional: restringe apenas ao protocolo moderno
set_sshd_option "Protocol" "2"

echo "[3/5] Validando sintaxe da configuração..."
sshd -t

echo "[4/5] Reiniciando serviço SSH..."
systemctl restart ssh || systemctl restart sshd

echo "[5/5] Hardening aplicado com sucesso."
echo "Backup salvo em: ${SSHD_CONFIG}.bak_${BACKUP_SUFFIX}"
echo "Recomendação: integrar com Fail2Ban e monitoramento SIEM para resposta contínua."
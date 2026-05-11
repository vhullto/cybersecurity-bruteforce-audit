# REPORTE TÉCNICO - Auditoria de Força Bruta (Modelo Executivo Simplificado)

## 1. Resumo Executivo
- **Objetivo:** Avaliar exposição da infraestrutura a ataques de autenticação por força bruta/dicionário/spraying em ambiente controlado.
- **Escopo:** Serviços FTP, SSH e SMB em laboratório isolado.
- **Resultado macro:** Foi identificada fragilidade em política de credenciais, com potencial de comprometimento de acesso remoto.

## 2. Contexto e Escopo
- **Ambiente:** Host-Only (Kali Linux x Metasploitable 2).
- **Período da avaliação:** `AAAA-MM-DD HH:MM` até `AAAA-MM-DD HH:MM`.
- **Premissas:** Testes autorizados, sem impacto intencional de disponibilidade.

## 3. Principais Achados
### Achado 01 - Credencial fraca/padrão aceita em serviço crítico
- **Serviço impactado:** SSH (exemplo)
- **Evidência:** autenticação bem-sucedida via wordlist controlada.
- **Classificação de risco:** Alto
- **Probabilidade:** Alta
- **Impacto:** Alto

### Achado 02 - Ausência/fragilidade de mecanismos anti-brute-force
- **Evidência:** inexistência de lockout eficaz e/ou limitação de tentativas.
- **Classificação de risco:** Médio/Alto

## 4. Risco de Negócio
- Possibilidade de acesso não autorizado a ativos de infraestrutura.
- Potencial de movimento lateral e indisponibilidade operacional.
- Exposição regulatória por falhas de controle de acesso e rastreabilidade.

## 5. Recomendações Prioritárias
1. Habilitar MFA para contas administrativas e acesso remoto.
2. Aplicar políticas fortes de senha e remoção de credenciais padrão.
3. Implementar Fail2Ban/rate-limiting e account lockout balanceado.
4. Centralizar logs em SIEM com alertas de brute force e spraying.
5. Revalidar controles após hardening com novo ciclo de testes.

## 6. Plano de Ação (Exemplo)
- **D+7:** corrigir contas/senhas frágeis e desabilitar root login remoto.
- **D+15:** implantar lockout, Fail2Ban e regras de firewall.
- **D+30:** consolidar casos de uso SIEM e playbook SOC.

## 7. Status de Conformidade (Referencial)
- **Controle de Acesso:** Parcialmente aderente.
- **Monitoramento e Logging:** Parcialmente aderente.
- **Gestão de Vulnerabilidades:** Necessita melhorias.

## 8. Conclusão
A maturidade atual permite ganho rápido com controles de hardening de autenticação. O tratamento das fragilidades reduz significativamente risco operacional e risco de comprometimento de credenciais.
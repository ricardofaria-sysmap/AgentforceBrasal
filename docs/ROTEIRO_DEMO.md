# Roteiro da Demo — Agentforce RH Itaú

**Duração:** 20 minutos (15 min de demo + 5 min Q&A)
**Audiência:** Renzo (Itaú) + stakeholders
**Apresentadores:** Ricardo (condução técnica) + Luís (contexto de negócio)

## Estrutura

### Abertura (2 min) — Luís
- Contexto: evolução do I-Connecta com Agentforce
- Escopo da demo: jornada de férias como piloto, escalável para outras jornadas de RH (folha, benefícios, desligamento)
- Promessa: ver em funcionamento antes do acesso formal ao ambiente do Itaú

### Demo 1 — Dúvida simples (3 min) — Ricardo
Persona: **Marina**, colaboradora CLT
1. Abrir chat I-Connecta simulado
2. Perguntar: **"Posso dividir minhas férias em 3 partes?"**
3. Mostrar agente consultando KB e respondendo com citação da fonte
4. Destacar: resposta rápida, sem esperar RH, linguagem natural

### Demo 2 — Diferença CLT vs PJ (2 min) — Ricardo
Persona: **Pedro**, PJ
1. Perguntar: **"Sou PJ, tenho direito a 30 dias de férias?"**
2. Agente detecta regime e traz regra contratual distinta
3. Destacar: mesmo agente, contextualização por persona

### Demo 3 — Agendamento bem-sucedido (5 min) — Ricardo
Persona: **Marina** (volta ao chat)
1. Perguntar saldo: **"Quantos dias eu tenho disponíveis?"** → agente mostra
2. **"Quero marcar minhas férias"** → agente invoca Screen Flow automaticamente
3. Preencher datas (início hoje+45, retorno hoje+59)
4. Confirmar sem abono
5. Revisar tela de confirmação e submeter
6. Mostrar Case criado com Status "Pendente Aprovação"
7. Trocar para usuário **Carlos** (gestor): abrir Approval Request, aprovar
8. Voltar para Marina: mostrar e-mail de confirmação recebido
9. Destacar:
   - Determinismo das datas (nenhuma ambiguidade)
   - Validações automáticas invisíveis ao colaborador (quando tudo ok)
   - Aprovação roteada automaticamente ao manager
   - E-mail disparado + próximo e-mail agendado para 5 dias antes

### Demo 4 — Validação CLT bloqueando (2 min) — Ricardo
Persona: Marina novamente
1. **"Quero marcar férias"** → Screen Flow
2. Escolher data de início numa sexta-feira (ou véspera de feriado)
3. Mostrar tela de erro com mensagem clara
4. Corrigir e concluir
5. Destacar:
   - Regras CLT em código, não na cabeça do colaborador
   - Feedback imediato evita retrabalho e fila no RH

### Encerramento (1 min) — Luís
- Recapitular: 2 agentes, 1 experiência integrada
- Escopo de produção: multiplicar padrão para outras jornadas (reembolsos, folha, saúde)
- Próximos passos e timeline

## Slides de apoio sugeridos

1. **Capa** — Agentforce RH Itaú | I-Connecta 2.0
2. **Desafio** — % de tickets de RH que são dúvidas repetitivas (dado do Itaú, se disponível)
3. **Arquitetura** — o diagrama de [ARQUITETURA.md](ARQUITETURA.md#diagrama-de-componentes)
4. **Personas da demo** — Marina, Pedro, Carlos
5. **Métricas alvo** — redução de TMA, auto-atendimento, compliance CLT
6. **Roadmap** — onde mais aplicar o padrão (reembolsos, folha, onboarding)
7. **Próximos passos** — timeline, acessos, sprint 0

## Antes da demo (checklist dia D-1)

- [ ] Org funcional e com acesso externo (sandbox URL)
- [ ] 3 usuários com senhas redefinidas
- [ ] Saldo_Ferias__c populado nos 3 cenários
- [ ] Nenhum Case aberto que possa disparar e-mail indesejado
- [ ] Chat web acessível (URL pública do Embedded Service)
- [ ] Email Deliverability = "All email" na org
- [ ] Janelas/abas pré-abertas: Chat (Marina), Approval (Carlos), Email simulado
- [ ] Fonte "Feriados 2026" alinhada com data de demo

## Plano B

- Se Agentforce não responder: abrir Knowledge Article direto
- Se Screen Flow travar: mostrar gravação pré-feita
- Se Approval não disparar: abrir Case manualmente e mostrar o Record-Triggered Flow no debug log

# Screen Flow `Agendamento_Ferias_Screen`

## Metadados

- API Name: `Agendamento_Ferias_Screen`
- Type: Screen Flow
- Run In System Mode: sim (para ler `User.ManagerId` mesmo sem sharing explícito)
- Invocável por: Agentforce Custom Action + botão de Quick Action no Home

## Variáveis / Recursos

### Input
| Nome | Tipo | Descrição |
|---|---|---|
| `varUserId` | Text | default `{!$User.Id}` |

### Internas
| Nome | Tipo | Descrição |
|---|---|---|
| `varSaldoRec` | SObject `Saldo_Ferias__c` | registro carregado via Get Records |
| `varDataInicio` | Date | input do colaborador |
| `varDataRetorno` | Date | input do colaborador |
| `varVenderAbono` | Boolean | checkbox |
| `varDiasAbono` | Number (2,0) | input condicional |
| `varGestorId` | Text | ManagerId do colaborador |
| `varMensagemErro` | Text | mensagem consolidada para tela Erro |
| `varFeriados` | Collection<Date> | lista hardcoded de feriados 2026 |

### Formulas
| Nome | Expressão |
|---|---|
| `fxDiasSolicitados` | `{!varDataRetorno} - {!varDataInicio} + 1` |
| `fxLimiteAbono` | `FLOOR({!varSaldoRec.Dias_Direito__c} / 3) - {!varSaldoRec.Dias_Abono_Vendidos__c}` |
| `fxDataCriticaAviso` | `TODAY() + 30` |
| `fxDiaSemanaInicio` | `WEEKDAY({!varDataInicio})` |

### Output
| Nome | Tipo | Descrição |
|---|---|---|
| `varCaseId` | Text | ID do Case criado |

## Elementos do Flow

### 1. `Get_Saldo_Atual` (Get Records)
- Objeto: `Saldo_Ferias__c`
- Filtros: `Colaborador__c = {!varUserId}` AND `Status__c = 'Vigente'`
- Store: primeiro registro em `varSaldoRec`

### 2. `Get_Manager` (Get Records)
- Objeto: `User`
- Filtros: `Id = {!varUserId}`
- Store fields: `ManagerId` → atribui a `varGestorId`

### 3. Tela `Boas_Vindas_Saldo`
- Display Text com cabeçalho "Olá, {!$User.FirstName}!"
- Display Text com tabela resumo (Direito / Tirados / Disponíveis / Prazo concessivo)
- Botões: "Continuar", "Cancelar"

### 4. Tela `Selecao_Datas`
- Date Input `dataInicio` → `varDataInicio` (required)
- Date Input `dataRetorno` → `varDataRetorno` (required)
- Display Text dinâmico: "Total: {!fxDiasSolicitados} dias corridos"
- Validação inline: `varDataRetorno > varDataInicio`

### 5. Decision `Valida_CLT`
Rotas (ordem de avaliação):

| Rota | Critério | Próxima ação |
|---|---|---|
| Erro_Aviso_30d | `varDataInicio < fxDataCriticaAviso` | set `varMensagemErro` + Tela_Erro |
| Erro_Saldo | `fxDiasSolicitados > varSaldoRec.Dias_Disponiveis__c` | idem |
| Erro_Minimo_5 | `fxDiasSolicitados < 5` | idem |
| Erro_Concessivo | `varDataRetorno > varSaldoRec.Periodo_Concessivo_Fim__c` | idem |
| Erro_Dia_Semana | `fxDiaSemanaInicio IN (5,6,7)` | idem |
| Erro_Vespera_Feriado | `varDataInicio + 1` ∈ `varFeriados` OR `varDataInicio + 2` ∈ `varFeriados` | idem |
| Erro_Fracionamento | já existe Case aprovado no aquisitivo sem período >= 14 E este pedido < 14 | idem |
| OK | default | Decision_Abono |

### 6. Decision `Decision_Abono`
- Rota "Mostrar": `varSaldoRec.Dias_Abono_Vendidos__c < fxLimiteAbono`
- Rota "Pular": caso contrário → direto para `Confirmacao`

### 7. Tela `Abono` (condicional)
- Checkbox `varVenderAbono`
- Number Input `varDiasAbono` (condicional, visível apenas se checkbox marcado)
- Validação: `varDiasAbono <= fxLimiteAbono`

### 8. Tela `Confirmacao`
- Display Text com resumo (datas, total, abono se aplicável, gestor aprovador)
- Checkbox required "Confirmo que as informações estão corretas"
- Botões: "Voltar", "Enviar para aprovação"

### 9. `Create_Case` (Create Records)
- Objeto: `Case`
- Valores:
  - `RecordTypeId` = Id do RT `Pedido_Ferias`
  - `Subject` = "Pedido de Férias — {!$User.FullName} — {!varDataInicio}"
  - `Status` = "Pendente Aprovacao"
  - `Origin` = "Agentforce Chat"
  - `OwnerId` = `{!varGestorId}`
  - `Data_Inicio_Ferias__c` = `{!varDataInicio}`
  - `Data_Retorno_Ferias__c` = `{!varDataRetorno}`
  - `Vender_Abono__c` = `{!varVenderAbono}`
  - `Dias_Abono__c` = `{!varDiasAbono}`
  - `Saldo_Ferias_Ref__c` = `{!varSaldoRec.Id}`
  - `Gestor__c` = `{!varGestorId}`
- Store Id em `varCaseId`

### 10. `Submit_For_Approval` (Action — Submit for Approval)
- Approval Process: `Aprovacao_Pedido_Ferias`
- Record Id: `{!varCaseId}`
- Submitter Comment: "Submetido via Agentforce"

### 11. Tela `Sucesso`
- Display Text: "Seu pedido foi encaminhado ao gestor."
- Display Text: "Protocolo: **{!varCaseId}**"
- Botão: "Concluir"

### 12. Tela `Erro`
- Display Text (ícone warning): `{!varMensagemErro}`
- Botões: "Corrigir datas" (volta para `Selecao_Datas`) | "Cancelar"

## Testes de caixa-preta

| Cenário | Input | Resultado esperado |
|---|---|---|
| Happy path | início hoje+45, retorno +59, 15 dias, com saldo 30 | Case criado, Approval submetido |
| Aviso curto | início hoje+10 | Tela_Erro V1 |
| Saldo insuficiente | 25 dias com saldo 15 | Tela_Erro V2 |
| Fim de semana | início num sábado | Tela_Erro V5 |
| Véspera feriado | 24/12 (véspera de 25/12) | Tela_Erro V6 |
| Abono excedido | abono 15 com direito 30 | erro inline na tela Abono |

#!/usr/bin/env bash
# bootstrap-data.sh — cria os 3 registros Saldo_Ferias__c para as personas
# Uso: ./scripts/bootstrap-data.sh <alias-da-org>

set -euo pipefail

ORG_ALIAS="${1:-itau-demo}"

echo "==> Populando Saldo_Ferias__c na org $ORG_ALIAS"

get_user_id() {
  local username="$1"
  sf data query \
    -o "$ORG_ALIAS" \
    -q "SELECT Id FROM User WHERE Username = '$username' LIMIT 1" \
    --json | jq -r '.result.records[0].Id'
}

MARINA_ID=$(get_user_id "marina.colaboradora@itau.demo.local")
PEDRO_ID=$(get_user_id "pedro.colaborador@itau.demo.local")
CARLOS_ID=$(get_user_id "carlos.gestor@itau.demo.local")

echo "  Marina.Id = $MARINA_ID"
echo "  Pedro.Id  = $PEDRO_ID"
echo "  Carlos.Id = $CARLOS_ID"

create_saldo() {
  local nome="$1"
  local user_id="$2"
  local regime="$3"
  local inicio="$4"
  local faltas="$5"
  local tirados="$6"

  echo ""
  echo "  Criando: $nome"
  sf data create record \
    -o "$ORG_ALIAS" \
    -s Saldo_Ferias__c \
    -v "Colaborador__c=$user_id Regime_Contratacao__c=$regime Periodo_Aquisitivo_Inicio__c=$inicio Faltas_Injustificadas__c=$faltas Dias_Tirados__c=$tirados Dias_Abono_Vendidos__c=0 Status__c=Vigente"
}

create_saldo "Saldo Marina 2025" "$MARINA_ID" "CLT" "2025-03-01" "2" "0"
create_saldo "Saldo Pedro 2025"  "$PEDRO_ID"  "PJ"  "2025-01-15" "0" "5"
create_saldo "Saldo Carlos 2025" "$CARLOS_ID" "CLT" "2024-11-01" "0" "20"

echo ""
echo "Saldos criados. Validacao rapida:"
sf data query \
  -o "$ORG_ALIAS" \
  -q "SELECT Name, Colaborador__r.Name, Regime_Contratacao__c, Dias_Direito__c, Dias_Tirados__c, Dias_Disponiveis__c, Status__c FROM Saldo_Ferias__c ORDER BY CreatedDate DESC LIMIT 10"

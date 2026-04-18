#!/usr/bin/env bash
# create-users.sh — cria as 3 personas da demo e define a hierarquia de manager
# Uso: ./scripts/create-users.sh <alias-da-org>

set -euo pipefail

ORG_ALIAS="${1:-itau-demo}"

echo "==> Criando Users na org $ORG_ALIAS"

for persona in carlos marina pedro; do
  echo ""
  echo "-- $persona"
  sf org create user \
    -o "$ORG_ALIAS" \
    -f "config/user-${persona}.json" \
    --set-alias "demo-${persona}" \
    || echo "  (usuario ja existe ou falhou — prosseguindo)"
done

echo ""
echo "==> Definindo hierarquia: Carlos e manager de Marina e Pedro"

CARLOS_ID=$(sf data query \
  -o "$ORG_ALIAS" \
  -q "SELECT Id FROM User WHERE Username = 'carlos.gestor@itau.demo.local' LIMIT 1" \
  --json | jq -r '.result.records[0].Id')

if [ -z "$CARLOS_ID" ] || [ "$CARLOS_ID" = "null" ]; then
  echo "ERRO: nao consegui encontrar o user Carlos."
  exit 1
fi

echo "  Carlos.Id = $CARLOS_ID"

for username in marina.colaboradora@itau.demo.local pedro.colaborador@itau.demo.local; do
  echo "  Atualizando manager de $username"
  USER_ID=$(sf data query \
    -o "$ORG_ALIAS" \
    -q "SELECT Id FROM User WHERE Username = '$username' LIMIT 1" \
    --json | jq -r '.result.records[0].Id')
  sf data update record \
    -o "$ORG_ALIAS" \
    -s User \
    -i "$USER_ID" \
    -v "ManagerId=$CARLOS_ID"
done

echo ""
echo "Users criados. Senhas em: sf org display user -o <alias-da-persona>"

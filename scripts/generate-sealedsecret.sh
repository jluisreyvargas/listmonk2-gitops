#!/usr/bin/env bash
set -euo pipefail

# Requisitos:
# - kubectl (apuntando al cluster)
# - kubeseal (cli)
# - Sealed Secrets controller instalado (repo-infra)

NAMESPACE="listmonk"
NAME="listmonk-secrets"
OUT="apps/listmonk/overlays/local/sealedsecrets/sealedsecret-listmonk.yaml"

: "${DB_USER:?export DB_USER}"
: "${DB_PASSWORD:?export DB_PASSWORD}"
: "${ADMIN_USER:?export ADMIN_USER}"
: "${ADMIN_PASSWORD:?export ADMIN_PASSWORD}"

# Crea un Secret efímero en stdout y lo sella con el cert del cluster
kubectl -n "$NAMESPACE" create secret generic "$NAME" \
  --from-literal=db_user="$DB_USER" \
  --from-literal=db_password="$DB_PASSWORD" \
  --from-literal=admin_user="$ADMIN_USER" \
  --from-literal=admin_password="$ADMIN_PASSWORD" \
  --dry-run=client -o yaml \
| kubeseal \
    --controller-name sealed-secrets \
    --controller-namespace sealed-secrets \
    --format yaml \
  > "$OUT"

echo "Generado: $OUT"

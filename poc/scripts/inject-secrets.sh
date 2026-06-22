#!/usr/bin/env bash
# Injects secrets from the gitignored .env into the cluster as Kubernetes
# Secrets. Idempotent: re-running updates the secrets in place. Nothing here is
# ever committed; the manifests in git reference these secrets by name only.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ENV_FILE="${ROOT}/.env"

if [ ! -f "${ENV_FILE}" ]; then
  echo "ERROR: ${ENV_FILE} not found. Copy .env.example to .env and fill it in."
  exit 1
fi

# shellcheck disable=SC1090
set -a; source "${ENV_FILE}"; set +a

NS="gravitee"
kubectl get namespace "${NS}" >/dev/null 2>&1 || kubectl create namespace "${NS}"

# ManagementContext auth: the GKO operator uses this to call the Management API.
echo "Injecting secret: gravitee-mgmt-context-auth (namespace ${NS})"
kubectl create secret generic gravitee-mgmt-context-auth \
  --namespace "${NS}" \
  --from-literal=username="${GRAVITEE_ADMIN_USER:-admin}" \
  --from-literal=password="${GRAVITEE_ADMIN_PASSWORD:-admin}" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Done."

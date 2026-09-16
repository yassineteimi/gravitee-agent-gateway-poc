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

# Gravitee Enterprise license. The chart only mounts its own license secret when
# license.key is set IN THE VALUES FILE, which would mean committing the signed
# key to git. Instead we create the secret here from the gitignored key file and
# mount it through gateway/api extraVolumes (see poc/helm/gravitee-values.yaml).
# Accepted sources, in order: $GRAVITEE_LICENSE_FILE, a licence/license file at
# the repo root, or a base64 one-liner in $GRAVITEE_LICENSE.
LICENSE_FILE=""
for candidate in "${GRAVITEE_LICENSE_FILE:-}" "${ROOT}/licence.txt" "${ROOT}/license.txt" "${ROOT}/license.key"; do
  if [ -n "${candidate}" ] && [ -f "${candidate}" ]; then LICENSE_FILE="${candidate}"; break; fi
done

if [ -z "${LICENSE_FILE}" ] && [ -n "${GRAVITEE_LICENSE:-}" ]; then
  LICENSE_FILE="$(mktemp)"
  printf '%s' "${GRAVITEE_LICENSE}" > "${LICENSE_FILE}"
  trap 'rm -f "${LICENSE_FILE}"' EXIT
fi

if [ -n "${LICENSE_FILE}" ]; then
  # Gravitee reads license.key as a BINARY license3j file. What you are handed
  # (Gravitee Cloud, the "copy your license" field, the value the chart wants in
  # license.key) is that file rendered as base64 text. Feeding the text straight
  # in gets you "serialized license is corrupt" at gateway startup, so decode it
  # here when the file is base64 text and pass a binary file through untouched.
  LICENSE_BIN="$(mktemp)"
  trap 'rm -f "${LICENSE_BIN}"' EXIT
  if tr -d '\n\r' < "${LICENSE_FILE}" | grep -qE '^[A-Za-z0-9+/]+={0,2}$'; then
    echo "License file is base64 text: decoding to the binary form Gravitee expects"
    tr -d '\n\r' < "${LICENSE_FILE}" | base64 -d > "${LICENSE_BIN}"
  else
    cat "${LICENSE_FILE}" > "${LICENSE_BIN}"
  fi

  echo "Injecting secret: gravitee-license (namespace ${NS}, from $(basename "${LICENSE_FILE}"))"
  kubectl create secret generic gravitee-license \
    --namespace "${NS}" \
    --from-file=licensekey="${LICENSE_BIN}" \
    --dry-run=client -o yaml | kubectl apply -f -
else
  echo "No license found (skipping gravitee-license). Enterprise gates stay off."
fi

echo "Done."

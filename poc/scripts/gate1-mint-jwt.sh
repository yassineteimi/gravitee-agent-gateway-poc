#!/usr/bin/env bash
# Mints a short-lived RS256 JWT for the Echo API's JWT plan, signed with the demo
# private key from the gitignored .env (the matching public key is in
# echo-api.yaml). The token's client_id claim matches the echo-jwt-consumer
# application, so the gateway resolves it to that subscription.
#
# Prints ONLY the token on stdout, so it pipes cleanly:
#   JWT=$(./poc/scripts/gate1-mint-jwt.sh)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ENV_FILE="${ROOT}/.env"
[ -f "${ENV_FILE}" ] && { set -a; source "${ENV_FILE}"; set +a; }
: "${GATE1_JWT_PRIVATE_KEY_B64:?not set in .env (run the key-generation step first)}"

CLIENT_ID="echo-jwt-client"
TMPKEY="$(mktemp)"
trap 'rm -f "${TMPKEY}"' EXIT
printf '%s' "${GATE1_JWT_PRIVATE_KEY_B64}" | base64 -d > "${TMPKEY}"

b64url() { openssl base64 -A | tr '+/' '-_' | tr -d '='; }

now=$(date +%s)
exp=$((now + 3600))
header='{"alg":"RS256","typ":"JWT"}'
payload="{\"iss\":\"gate1-demo\",\"sub\":\"demo-user\",\"client_id\":\"${CLIENT_ID}\",\"iat\":${now},\"exp\":${exp}}"

h=$(printf '%s' "${header}"  | b64url)
p=$(printf '%s' "${payload}" | b64url)
sig=$(printf '%s' "${h}.${p}" | openssl dgst -sha256 -sign "${TMPKEY}" -binary | b64url)

echo "${h}.${p}.${sig}"

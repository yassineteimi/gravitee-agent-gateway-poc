#!/usr/bin/env bash
# Subscribes the GKO-declared "Echo Consumer" application to the Echo API's
# API-key plan and prints the generated API key.
#
# Why this is a script and not a GKO Subscription CRD: GKO's Subscription
# resource only accepts an API-key plan if you embed the key in the manifest,
# which would commit a credential to git. API keys are runtime secrets, so we
# mint one through the Management API here and never persist it. The API, plan,
# and consumer application are all still declared as code (GKO); only the key
# generation is runtime.
#
# Idempotent: reuses an existing active subscription if one is already present.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ENV_FILE="${ROOT}/.env"
[ -f "${ENV_FILE}" ] && { set -a; source "${ENV_FILE}"; set +a; }
USER="${GRAVITEE_ADMIN_USER:-admin}"
PASS="${GRAVITEE_ADMIN_PASSWORD:-admin}"

API_NAME="Echo API"
APP_NAME="Echo Consumer"
PLAN_SECURITY="API_KEY"

# Port-forward the Management API for the duration of the script.
kubectl port-forward -n gravitee svc/gravitee-apim-api 8083:83 >/dev/null 2>&1 &
PF_PID=$!
trap 'kill ${PF_PID} 2>/dev/null || true' EXIT
for _ in $(seq 1 20); do
  curl -s -o /dev/null "http://localhost:8083/management" && break || sleep 1
done

V1="http://localhost:8083/management/organizations/DEFAULT/environments/DEFAULT"
V2="http://localhost:8083/management/v2/organizations/DEFAULT/environments/DEFAULT"
AUTH=(-u "${USER}:${PASS}")

jqpy() { python3 -c "import sys,json;$1" ; }

api_id=$(curl -s "${AUTH[@]}" "${V2}/apis?perPage=50" | jqpy "
d=json.load(sys.stdin)
print(next((a['id'] for a in d['data'] if a['name']=='${API_NAME}'),''))")
[ -n "${api_id}" ] || { echo "ERROR: API '${API_NAME}' not found (is it deployed?)"; exit 1; }

plan_id=$(curl -s "${AUTH[@]}" "${V2}/apis/${api_id}/plans?perPage=50" | jqpy "
d=json.load(sys.stdin)
print(next((p['id'] for p in d['data'] if p.get('security',{}).get('type')=='${PLAN_SECURITY}'),''))")
[ -n "${plan_id}" ] || { echo "ERROR: ${PLAN_SECURITY} plan not found on '${API_NAME}'"; exit 1; }

app_id=$(curl -s "${AUTH[@]}" "${V1}/applications" | jqpy "
d=json.load(sys.stdin)
print(next((a['id'] for a in (d if isinstance(d,list) else d.get('data',[])) if a['name']=='${APP_NAME}'),''))")
[ -n "${app_id}" ] || { echo "ERROR: application '${APP_NAME}' not found"; exit 1; }

# Reuse an existing subscription to this plan, otherwise create one.
sub_id=$(curl -s "${AUTH[@]}" "${V1}/applications/${app_id}/subscriptions" | jqpy "
d=json.load(sys.stdin)
subs=d.get('data', d if isinstance(d,list) else [])
print(next((s['id'] for s in subs if s.get('plan')=='${plan_id}'),''))" 2>/dev/null || true)

if [ -z "${sub_id}" ]; then
  sub_id=$(curl -s "${AUTH[@]}" -X POST -H 'Content-Type: application/json' \
    "${V1}/applications/${app_id}/subscriptions?plan=${plan_id}" | jqpy "print(json.load(sys.stdin).get('id',''))")
  echo "Created subscription ${sub_id}"
else
  echo "Reusing subscription ${sub_id}"
fi

api_key=$(curl -s "${AUTH[@]}" "${V1}/applications/${app_id}/subscriptions/${sub_id}/apikeys" | jqpy "
d=json.load(sys.stdin)
ks=[k for k in (d if isinstance(d,list) else d.get('data',[])) if not k.get('revoked')]
print(ks[0]['key'] if ks else '')")
[ -n "${api_key}" ] || { echo "ERROR: no API key found for subscription"; exit 1; }

echo ""
echo "API key: ${api_key}"
echo ""
echo "Try it:"
echo "  curl -H \"X-Gravitee-Api-Key: ${api_key}\" \\"
echo "    --resolve gateway.gravitee.local:80:127.0.0.1 http://gateway.gravitee.local/echo"

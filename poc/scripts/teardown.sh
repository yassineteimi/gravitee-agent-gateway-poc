#!/usr/bin/env bash
# Clean teardown: delete the kind cluster. The Colima VM is left running; stop it
# separately with `colima stop` if desired.
set -euo pipefail

CLUSTER="gravitee"

if kind get clusters 2>/dev/null | grep -qx "${CLUSTER}"; then
  echo "Deleting kind cluster '${CLUSTER}'..."
  kind delete cluster --name "${CLUSTER}"
  echo "Cluster removed."
else
  echo "No kind cluster '${CLUSTER}' to delete."
fi

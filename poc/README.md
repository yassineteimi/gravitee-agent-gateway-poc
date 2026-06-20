# poc/ - the runnable proof of concept

This half of the repository is what actually runs on the homelab. The published
tutorial lives in `docs/`; this directory holds the manifests, Helm values,
ArgoCD applications, and scripts that the tutorial documents.

```text
poc/
├── cluster/        # local Kubernetes cluster config + bootstrap
├── argocd/         # ArgoCD install + app-of-apps (root-app + apps/)
├── helm/           # Gravitee APIM Helm values (pinned chart version)
├── gate1-api/      # Gate 1: sample API + plan + rate-limit/quota
├── gate2-ai/       # Gate 2: LLM proxy + MCP + A2A governance
├── gate3-event/    # Gate 3: Kafka gateway + access control
├── observability/  # OpenTelemetry + Prometheus + Grafana
└── scripts/        # idempotent bootstrap, teardown, secret injection
```

Everything is reconciled by ArgoCD (GitOps): changes are committed, then synced.
Secrets come from a gitignored `.env` at the repo root, injected as Kubernetes
Secrets by the scripts here. Nothing secret is committed.

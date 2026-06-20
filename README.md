<h1 align="center">Gravitee Agent Gateway PoC</h1>

<p align="center">
  <b>API Gateway · AI / Agent Gateway · Event Gateway</b>: one control point for API, AI, and event traffic<br/>
  GitOps-first on a local Kubernetes homelab · ArgoCD · declarative everything
</p>

<p align="center">
  <a href="https://yassineteimi.github.io/gravitee-agent-gateway-poc/"><b>Read the tutorial and benchmark</b></a>
</p>

---

A hands-on benchmark of **[Gravitee](https://www.gravitee.io/)** as a single control point that governs three kinds of traffic as defense in depth: classic **APIs**, **AI and agent** traffic (LLM, MCP, A2A), and event-native **Kafka** streams. Everything is reconciled declaratively by **ArgoCD** and runs on a single-node Kubernetes homelab.

It deliberately mirrors a companion [Traefik Hub Triple Gate PoC](https://github.com/yassineteimi/traefik-hub-triple-gate), so the two platforms compare on the same ground with the same GitOps model.

## The three gates

| Gate | Enforces | Highlights |
| --- | --- | --- |
| **1: API Gateway** | Identity and abuse control on a sample API | A Plan (API key / JWT / OAuth2), rate limiting and quota, self-service via the Developer Portal, reconciled by ArgoCD |
| **2: AI / Agent Gateway** | Governance on LLM, MCP and agent traffic | LLM Proxy (prompt guardrails, PII filtering, token rate limiting, model routing), an API exposed as an MCP server with method-level access control, and A2A governance |
| **3: Event Gateway** | Access control on native Kafka | The event-native differentiator: secure a Kafka stream with a Plan and authentication mediation, plus protocol mediation to HTTP / SSE / WebSocket |

LLM traffic is routed to **NVIDIA hosted NIMs** (OpenAI-compatible), the same provider as the Traefik PoC, for a comparable benchmark.

## Repository layout

```text
gravitee-agent-gateway-poc/
├── docs/        # the published GitHub Pages tutorial (MkDocs Material)
└── poc/         # the runnable PoC: manifests, Helm values, ArgoCD apps, scripts
    ├── cluster/        # local cluster config + bootstrap
    ├── argocd/         # ArgoCD install + app-of-apps
    ├── helm/           # Gravitee APIM Helm values (pinned)
    ├── gate1-api/      # sample API + plan + rate-limit/quota
    ├── gate2-ai/       # LLM proxy + MCP + A2A governance
    ├── gate3-event/    # Kafka gateway + access control
    ├── observability/  # OpenTelemetry + Prometheus + Grafana
    └── scripts/        # idempotent bootstrap, teardown, secret injection
```

GitHub Pages is static and cannot run the cluster, so **`docs/` documents and presents** while **`poc/` runs** on the homelab.

## Secrets hygiene

All tokens, keys and the Gravitee license come from a **gitignored `.env`**, injected as Kubernetes Secrets by scripts, never committed. The published site contains zero secrets.

## Stack

![Gravitee](https://img.shields.io/badge/Gravitee-7D4CDB?logo=gravitee&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&logoColor=white)
![ArgoCD](https://img.shields.io/badge/Argo%20CD-EF7B4D?logo=argo&logoColor=white)
![Apache Kafka](https://img.shields.io/badge/Apache%20Kafka-231F20?logo=apachekafka&logoColor=white)
![NVIDIA NIM](https://img.shields.io/badge/NVIDIA%20NIM-76B900?logo=nvidia&logoColor=white)
![MCP](https://img.shields.io/badge/MCP-AI%20Agents-1F6FEB)
![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?logo=prometheus&logoColor=white)
![Grafana](https://img.shields.io/badge/Grafana-F46800?logo=grafana&logoColor=white)
![MkDocs Material](https://img.shields.io/badge/MkDocs-Material-526CFE?logo=materialformkdocs&logoColor=white)

## Connect

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0A66C2?logo=linkedin&logoColor=white)](https://linkedin.com/in/yassine-teimi)
[![Email](https://img.shields.io/badge/Email-EA4335?logo=gmail&logoColor=white)](mailto:yteimi@gmail.com)

---

<p align="center"><sub>A neutral technical benchmark of Gravitee for API, AI / agent, and event governance. Not affiliated with Gravitee.io.</sub></p>

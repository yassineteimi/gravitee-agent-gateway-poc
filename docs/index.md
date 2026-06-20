# Gravitee Agent Gateway PoC

A hands-on, homelab benchmark of **[Gravitee](https://www.gravitee.io/)** as a single control point for three kinds of traffic: classic **APIs**, **AI and agent** traffic (LLM, MCP, A2A), and **event streams** (native Kafka). Everything is reconciled declaratively by **ArgoCD** and runs on a single-node Kubernetes homelab.

The structure deliberately mirrors a companion [Traefik Hub Triple Gate PoC](https://yassineteimi.github.io/traefik-hub-triple-gate/), so the two platforms can be compared on the same ground, with the same GitOps model and the same milestone rhythm.

!!! note "Point in time"
    Gravitee moves fast. Everything here is dated and sourced, tested against a specific chart and product version recorded on the [Prerequisites](prerequisites.md) page. Treat it as a snapshot, not a permanent statement of capability.

## The three gates

| Gate | Enforces | Highlights |
| --- | --- | --- |
| **1: API Gateway** | Identity and abuse control on a sample API | A Plan (API key / JWT / OAuth2), rate limiting and quota, self-service via the Developer Portal, all declarative and reconciled by ArgoCD |
| **2: AI / Agent Gateway** | Governance on LLM, MCP and agent traffic | LLM Proxy (prompt guardrails, PII filtering, token rate limiting, model routing), an API exposed as an MCP server with method-level access control, and A2A agent-to-agent governance |
| **3: Event Gateway** | Access control and governance on native Kafka | The event-native differentiator: secure a Kafka stream with a Plan and authentication mediation, plus protocol mediation to HTTP / SSE / WebSocket |

Gate 3 has no equivalent in the Traefik PoC: governing native event streams as first-class APIs is Gravitee's distinctive capability, and it gets its own chapter here.

LLM traffic in Gate 2 is routed to **NVIDIA hosted NIMs** (OpenAI-compatible), the same provider used in the Traefik PoC, so the AI behaviour is comparable across both benchmarks.

## How to read this site

The site is a tutorial. Each chapter follows one milestone of the build:

- **[Prerequisites](prerequisites.md)** verifies the local toolchain and the Gravitee license, live.
- **[Architecture](architecture.md)** lays out the components and the request flow.
- **[Bootstrap (M0)](bootstrap.md)** stands up the cluster, ArgoCD, and Gravitee via Helm.
- **Gates [1](gates/api-gateway.md), [2](gates/ai-agent-gateway.md) and [3](gates/event-gateway.md)** build one enforcement point each.
- **[Unified Demo](unified-demo.md)** runs a single narrative across all three gates.
- **[Observability](observability.md)** captures the metrics and traces Gravitee emits.
- **[Evaluation Notes](evaluation.md)** is a neutral, sourced landscape, not a scoreboard.

## Secrets hygiene

All tokens, keys and the Gravitee license come from a **gitignored `.env`**, injected as Kubernetes Secrets by scripts, never committed. This published site contains zero secrets.

---

<sub>A neutral technical benchmark of Gravitee for API, AI / agent, and event governance. Not affiliated with Gravitee.io.</sub>

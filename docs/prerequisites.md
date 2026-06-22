# Prerequisites

Everything this PoC needs before the first install, verified live. The build runs
on a single-node Kubernetes homelab inside a local VM; nothing here needs a cloud
account, and Gate 1 needs no license at all.

## Platform

The reference environment is **macOS on Apple Silicon (arm64)**, with Docker
provided by a **Colima** VM. Any machine that can run `kind` works, but two
arm64-specific notes carry through the build:

- The Gravitee Kubernetes Operator ships a Go FIPS-140 build that is unstable on
  arm64 and needs `GODEBUG=fips140=off` (handled in [Gate 1](gates/api-gateway.md)).
- Container images for the bundled datastores moved to Bitnami's `bitnamilegacy`
  repository, which the chart must be told to accept (handled in
  [Bootstrap](bootstrap.md)).

## Toolchain

Versions are pinned and recorded so the build is reproducible:

| Tool | Version | Role |
| --- | --- | --- |
| Colima | 0.10.3 | Local VM + Docker runtime |
| kind | 0.32.0 | Kubernetes in Docker |
| kubectl | 1.31.2 | Cluster CLI |
| Helm | 4.2.2 | Chart tooling (ArgoCD renders charts itself) |
| ArgoCD CLI | 3.4.3 | GitOps engine, client and server pinned together |

On macOS these install from Homebrew:

```{ .sh .terminal }
$ brew install colima kind kubectl helm argocd
```

Verify each one is present before starting:

```{ .sh .terminal }
$ colima version
$ kind version
$ kubectl version --client
$ helm version --short
$ argocd version --client
```

## Sizing the VM

Gravitee's footprint is heavier than a typical gateway: a Gateway, a Management
API, a Console UI, a Developer Portal, plus a MongoDB configuration store and an
Elasticsearch analytics store. The VM is sized to hold all of it with room to
spare. On a 36 GiB / 12-core host, 8 CPU and 16 GiB leaves the desktop
comfortable:

```{ .sh .terminal }
$ colima start --cpu 8 --memory 16 --disk 60
```

## Accounts and keys

| What | Needed for | Notes |
| --- | --- | --- |
| Nothing | **Gate 1 (API)** | The whole API gateway, plans, rate limiting, and Developer Portal run on the open-source edition. |
| Gravitee EE trial license | **Gates 2 and 3** | The AI Gateway and Kafka Gateway are Enterprise features. A 14-day free trial unlocks them; the clock starts when the license is applied, so request it just before Gate 2. |
| NVIDIA NIM API key (`nvapi-...`) | **Gate 2 (AI)** | Free from build.nvidia.com. The LLM traffic is routed to NVIDIA hosted NIMs (OpenAI-compatible). |

## Secrets

Every secret lives in a single **gitignored `.env`** at the repo root and is
injected into the cluster as a Kubernetes Secret by the scripts in
`poc/scripts/`. The committed manifests reference secrets by name only; the
published site and the git history contain zero secrets.

```{ .sh .terminal }
$ cp .env.example .env
$ # fill in .env, then secrets are injected by the scripts that need them
```

With the toolchain verified, the VM sized, and `.env` in place, the next chapter
[bootstraps the cluster](bootstrap.md).

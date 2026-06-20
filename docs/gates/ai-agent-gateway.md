# Gate 2: AI / Agent Gateway

Governance on LLM, MCP and agent-to-agent traffic through one runtime: the LLM Proxy, an API exposed as an MCP server, and A2A governance.

!!! info "In progress"
    Written during **Milestone 2**. Routes LLM traffic to NVIDIA hosted NIMs through Gravitee's LLM Proxy with prompt guardrails, PII filtering and token rate limiting; exposes the Gate 1 API as an MCP server with method-level access control; and demonstrates A2A agent-to-agent governance. Honest notes on what is GA versus newer, and how Gravitee's model-managed access control differs from per-tool TBAC.

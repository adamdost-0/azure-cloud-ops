# Security notes

## Secrets
Do not commit credentials, keys, tokens, passwords, or connection strings to this repository.

If a secret is ever committed, treat it as compromised:
1) Rotate/revoke it immediately.
2) Consider rewriting git history (optional but recommended for truly sensitive material).

## Containers
Do not bake credentials into Docker images.
Pass secrets at runtime using your orchestrator (GitHub Actions secrets, Azure Key Vault, Kubernetes secrets, etc.).

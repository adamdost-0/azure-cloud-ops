---
title: "IaC (Bicep)"
permalink: /topics/iac-bicep/
layout: single
---

Infrastructure-as-code disciplines — naming conventions, secret handling, environment parity, and pre-deployment validation — are the foundation of reliable Azure platforms. These posts cover practical IaC patterns used in production.

## Featured posts

- [Understanding dependencies in Azure]({% post_url 2021-06-20-Understanding-dependencies-in-Azure %}) — Building a dependency skeleton in IaC: resource ordering, naming conventions, and environment modeling
- [Avoid exposing credentials with Azure KeyVault]({% post_url 2021-07-06-Avoid-exposing-credentials-with-KeyVault %}) — Passing KeyVault secret references in ARM/Bicep to keep credentials out of templates entirely
- [Securing my IaC with Checkmarx's KICS]({% post_url 2022-03-20-How-to-use-KICS-to-keep-you-safe %}) — Static analysis for IaC: detecting misconfigurations and credential exposure before deployment
- [Management Groups in Azure]({% post_url 2021-06-21-Management-Groups-and-Azure %}) — IaC-driven management group and policy hierarchy deployment patterns

## Focus areas

- **Bicep modules:** Reusable, parameterized modules for common Azure resource types
- **Naming and dependency modeling:** Consistent naming conventions and resource dependency graphs
- **Secure defaults in IaC:** KeyVault references, no hardcoded secrets, managed identity patterns
- **Pre-deployment validation:** KICS scanning, ARM What-If, policy compliance checks
- **Environment parity:** Using IaC to enforce consistency across dev, staging, and production

## Browse all posts

- All posts: [/posts/](/posts/)

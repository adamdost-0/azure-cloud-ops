---
title: "Security"
permalink: /topics/security/
layout: single
---

Security on Azure means building guardrails that operate at scale — not checklists applied after the fact. These posts cover secrets management, IaC scanning, policy enforcement, and secure-by-default design for commercial and government workloads.

## Featured posts

- [Avoid exposing credentials with Azure KeyVault]({% post_url 2021-07-06-Avoid-exposing-credentials-with-KeyVault %}) — KeyVault secret references in ARM/Bicep so credentials never appear in templates or logs
- [Securing my IaC with Checkmarx's KICS]({% post_url 2022-03-20-How-to-use-KICS-to-keep-you-safe %}) — Free open-source static analysis that catches misconfigurations before they reach Azure
- [Securing Azure Deployments with Azure Policy]({% post_url 2022-07-31-Securing-Azure-Deployments %}) — Policy-enforced baselines for IL-5: customer-managed keys, private endpoint requirements, and more
- [Audit Clipboard configuration for AVD]({% post_url 2023-05-21-Audit-Clipboard-for-AVD %}) — Policy-as-code to audit and enforce clipboard restrictions across Azure Virtual Desktop host pools
- [Compute isolation in Azure Government]({% post_url 2021-11-14-Compute-isolation-in-Azure-Government %}) — Dedicated host group patterns for DoD IL-5 compute isolation requirements

## Focus areas

- **Secrets management:** KeyVault integration in IaC, managed identity patterns, eliminating credential exposure
- **IaC security scanning:** KICS, credential scanning, misconfiguration detection pre-deployment
- **Policy enforcement:** Azure Policy for private endpoint requirements, CMK enforcement, and audit baselines
- **Government / regulated workloads:** IL-5 isolation, DISA STIG alignment, FedRAMP patterns

## Browse all posts

- All posts: [/posts/](/posts/)

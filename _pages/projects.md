---
title: "Projects"
permalink: /projects/
layout: single
---

Concise case studies and reference implementations designed for recruiters and hiring managers.

---

### AI + automation for platform operations

**What:** Automation patterns and AI-enabled workflows for ops and dev productivity — from IaC pipeline guardrails to policy-as-code tooling.

**Why it matters:** Faster, safer delivery with fewer manual steps and stronger pre-deployment validation gates.

**Reference work:**
- [Securing my IaC with KICS]({% post_url 2022-03-20-How-to-use-KICS-to-keep-you-safe %}) — Static analysis pipeline integration for IaC security scanning
- [GitHub repo: azure-cloud-ops](https://github.com/adamdost-0/azure-cloud-ops) — IaC patterns, policy examples, and deployment tooling

---

### Hub-spoke networking for private PaaS access

**What:** Hub-spoke topology with Azure Firewall, private endpoints, and private DNS resolution — enabling enterprise workloads to consume PaaS without public network exposure.

**Why it matters:** Reliable, auditable data paths and zero-trust network posture in production environments.

**Reference work:**
- [Containers on Azure]({% post_url 2021-06-22-Containers-and-Azure %}) — Private networking options for ACI, WebApp for Containers, and AKS
- [Securing Azure Deployments with Azure Policy]({% post_url 2022-07-31-Securing-Azure-Deployments %}) — Policy enforcement for private endpoint and public access baselines
- Detailed networking posts in progress — see [Networking topic](/topics/networking/)

---

### Azure landing zone + guardrails-first governance

**What:** Landing zone architecture with management-group hierarchy, subscription organization, and policy guardrails that enforce secure defaults across every workload at deployment time.

**Why it matters:** Prevents insecure configurations from reaching production and eliminates manual compliance review for known-good patterns.

**Reference work:**
- [Management Groups in Azure]({% post_url 2021-06-21-Management-Groups-and-Azure %}) — Subscription organization and inheritable policy at scale
- [Securing Azure Deployments with Azure Policy]({% post_url 2022-07-31-Securing-Azure-Deployments %}) — Six IL-5 baseline policies with source code
- [Audit Clipboard configuration for AVD]({% post_url 2023-05-21-Audit-Clipboard-for-AVD %}) — Policy-as-code for AVD baseline enforcement
- [Compute isolation in Azure Government]({% post_url 2021-11-14-Compute-isolation-in-Azure-Government %}) — Dedicated host deployment for DoD IL-5 requirements
- [GitHub repo: azure-cloud-ops](https://github.com/adamdost-0/azure-cloud-ops) — Policy definitions and IaC reference implementations

---
layout: post
title: "Azure OpenAI + IaC: Generating Guardrails as Code (Without Losing Human Control)"
date: 2026-02-08
categories: [azure, iac, ai, azure-openai]
tags: [Azure, IaC, Terraform, Bicep, Azure OpenAI, DevSecOps, Policy as Code]
---

## TL;DR

Azure OpenAI can accelerate how you create and maintain **guardrails as code** (policy, naming, tagging, security baselines) and how you review infrastructure changes—**without** giving up human control.

The win isn’t “AI writes infra.” The win is: **AI drafts guardrails and PR context, humans approve, CI verifies, and deployments stay diff-first.**

---

## Why this matters

Infrastructure-as-Code is only as good as the standards behind it. Azure environments drift when guardrails are:

- undocumented
- tribal knowledge
- inconsistent across repos/subscriptions
- applied after the fact (audit-only) instead of shift-left

Most teams don’t *lack* standards—they lack the time to encode and evolve them into something repeatable.

---

## The pattern: AI-assisted guardrails, human-approved changes

Here’s the workflow that holds up in real teams:

1. **Define intent once** (in plain English)
2. **Use Azure OpenAI to draft the first pass** of guardrails as code
3. **Enforce via PR-first, diff-first** workflows (plan/what-if captured)
4. **Iterate continuously** as patterns evolve

The core idea is simple: keep AI in the *drafting lane* and keep humans and CI in the *approval lane*.

---

## Step 1 — Define “policy intent” (the guardrails you actually want)

Examples of intent statements that map cleanly into code:

- Required tags: `Owner`, `CostCenter`, `DataClassification`
- Allowed regions (and explicit disallowed regions)
- Private networking required for PaaS services
- Minimum TLS versions for web-facing endpoints
- Diagnostic settings required (send logs/metrics to Log Analytics)

This is where leadership, security, and platform engineering align.

---

## Step 2 — Use Azure OpenAI to generate guardrails as code (first pass)

Azure OpenAI is ideal for producing **starter implementations** you can refine:

- Azure Policy definitions and initiatives (JSON)
- Terraform modules that enforce tags/diagnostics/private endpoints
- Bicep modules that bake in baseline settings
- CI steps that lint/scan/validate
- Documentation that explains “how to comply”

### Example prompt (Policy)

> Generate an Azure Policy initiative that enforces required tags (Owner, CostCenter, DataClassification) and requires diagnostic settings for Key Vault, Storage, and SQL to a specified Log Analytics workspace. Provide policy definitions and the initiative JSON.

### Example prompt (Module)

> Draft a Terraform module wrapper that ensures any `azurerm_*` resource created by the module includes required tags and diagnostic settings to a given Log Analytics workspace. Provide inputs/outputs and example usage.

Azure OpenAI won’t know your exact org’s conventions—but it *will* accelerate you to a strong baseline.

---

## Step 3 — Enforce via PR-first, diff-first workflows

This is where the safety comes from.

Recommended gates:

- **All changes are PRs** (no direct edits to main)
- **Terraform**: `plan` output captured as PR artifact/comment
- **Bicep**: `what-if` output captured and reviewed
- **Humans approve** before merge
- **CI verifies** before deploy

### What Azure OpenAI can do here

- Draft PR descriptions: intent, impact, risks, rollback
- Summarize diffs for reviewers
- Flag risk hotspots (identity/networking/public exposure)

#### Example prompt (PR write-up)

> Given these changed files and this Terraform plan output, draft a PR description with: intent, impact summary, risk assessment, test plan, and rollback steps.

---

## Step 4 — Add an AI reviewer assistant (human still approves)

A practical approach: run an “AI review” step that comments on PRs *without merging anything*.

The assistant can check for:

- accidental public endpoints
- secrets committed to repo
- missing tags/diagnostics
- policy bypasses
- non-standard naming

Think of it as a consistent second opinion.

---

## The safety model: keep AI out of production writes

Rules that prevent bad days:

- AI can **draft** code, docs, and suggestions
- Humans **approve and merge**
- CI **verifies** (formatting, security, policy)
- Deployments are automated **but gated**

This reduces:

- accidental exposures
- configuration drift
- “we forgot tags/diagnostics”
- hidden breaking changes

---

## Reference repo structure (simple and scalable)

A straightforward layout:

- `modules/` (Terraform/Bicep reusable modules)
- `policies/` (Azure Policy JSON + deployment templates)
- `.github/workflows/` (fmt/lint/security/policy checks)
- `docs/` (standards and how-to)

CI gates to consider:

- `terraform fmt -check`
- `tflint`
- `tfsec`
- secret scanning (gitleaks + GitHub secret scanning)
- markdown link checking

---

## Common mistakes to avoid

- Letting AI apply changes directly to production
- No standard prompt templates (results become inconsistent)
- No golden modules (teams reinvent solutions)
- Not capturing plan/what-if outputs in PRs
- Storing credentials in code or container images

---

## “Start small” playbook (one week)

**Day 1–2:** Write policy intent in plain English (1–2 pages)

**Day 3:** Generate initial Policy/Module skeletons with Azure OpenAI

**Day 4:** Add PR gates and plan/what-if outputs

**Day 5:** Run one real change end-to-end through PR + review

---

## Closing

Azure OpenAI isn’t a replacement for engineering discipline—it’s an amplifier for it.

If you combine AI-assisted drafting with human approval and CI verification, you can ship secure, standardized Azure infrastructure faster—with fewer regressions.

If you want, I can publish a follow-up that shows:

- a concrete Terraform example (plan comments + guardrail module)
- a concrete Bicep example (what-if + baseline module)
- a “PR reviewer assistant” prompt pack for Azure IaC

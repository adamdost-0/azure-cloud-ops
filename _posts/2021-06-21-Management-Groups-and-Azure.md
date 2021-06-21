---
title: "Management Groups in Azure"
categories:
  - Fundamentals
  - Azure
  - Governance
tags:
  - rbac
  - management
  - code
---

When beginning your cloud journey in Azure you'll find more value in investing in resource management and inheriting their current security policy into the Cloud for a smoother migration. To help start that process let's talk about Azure Management Groups and how they can empower you to do more inside of your org.

Management Groups are an Azure resource that allows you to catalog Azure subscriptions and other management groups inside of it for an inhertiable policy. A common example is if there's a security policy that **everyone** would need to inherit then assigning it at the top level would be most efficient in continously monitoring and enforcing rules in the environmnent! Permissions work in a similar fashion if you assign someone a role at the management group level then all child resources underneath it will inherit that permission down to the resource level. A common example that Microsoft uses is department level management groups that each manage their own subscription. 

When working in the regulated industries space you'll find it best to group subscriptions by the portfolio. This allows an organization to assign the portfolio owners at the top level of the management group so that they have insight into their entire business from a single pane. If they wanted to query or audit their applications then they would be able to without going through a centralized Ops team allowing the central group to focus more on their goals. 

## Azure Policy

Azure Policy is a service in Azure that allows you to perform API level enforcement of the Azure environment you scope it to. This means you can write policies for the organization at scale and control configuration drift to ensure that nothing goes out of compliance on the Azure environment. An easy introduction into Azure Policy is Azure Storage and the rules you can define to help harden the service in your workload. 

1. Deny the ability to allow blob access without authentication/authorization
2. All Storage accounts must allow by exception.

With Azure Policy you can define and enforce these rules for your environment and the platform will in turn enforce them during every deployment in scope of the policy.

## Validate everything

Do not deploy Azure policy to your root (/) management group in Azure. Only breakglass accounts which are monitored for actions and logins should have access to that root group. Start your Azure policy development in a single resource group and scale when you have validated everything. Because Azure Policy engine takes a moment to kick in you'll have a significantly **better** experience by scaling the scope of the policy after validating it is behaving as expected. 

When Azure Policy is misconfigured **everyone** loses. When managing operations in shared environment you have to be aware that actions with Azure Policy do affect end users and will need to be communicated out before implemented. Initial Communication about the change will help relieve your Ops team of being burdened with endless tickets about why X,Y,Z changed and if they aren't assisted *immediately* they start to drag leadership teams in which will significantly slow down the process. The "Security" part of DevSecOps is a growing part of every organization but it's not just a checkbox it's a process that you will need to communicatae with your end users.

Good luck to all deploying management groups in Azure! We'll have some fun sample code on building management groups via Code to show how you can build a multi-department environment and review it properly.
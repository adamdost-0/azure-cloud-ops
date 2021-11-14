---
title: "How do I isolate a VM in Azure Government? EZ"
categories:
  - azure
tags:
  - sysadmin
---

When working with the Department of Defense (DoD) comes with the regulatory requirements that are in place to ensure that they can operate. As the DoD continues to embrace new commercial solutions into their business it must adhere to their standards. If you work on the Microsoft Cloud you are most likely very familiar with [this page](https://docs.microsoft.com/en-us/azure/azure-government/documentation-government-impact-level-5). Let's try to take the guidance from this page and deploy a basic virtual machine from it.

When building a VM there are several "requirements" tied to building one. First is the network, second is the storage and third is the compute sku. Let's breakdown each piece....

> What is needed to isolate the compute?

Azure Dedicated Host is the answer. A short summary would be you get a dedicated blade just to yourself to run compute off of it. 

---
title: "Securing Azure Deployments with Azure Policy"
categories:
  - azure
tags:
  - policy
---



When working in collaboration environments baseline guard rails ensure that if differnt teams leverage different design implementation methods that there is a common enforcement point that will stop a deployment from deviating from a baseline configuration. Azure Policy is the standard in enforcing these decisions at the Azure Resource Manager making it agnostic of someone using Terraform/Bicep/Pulumi and more. One key factor is ensuring that Impact Level 5 workloasd that center around Azure Platform As a Service resources leverage customer managed keys and have their public conenctivity removed and enforced via Private Endpoints. The following GitHub Repo Contains 6 sample Azure Policies to help jumpstart several baseline Azure Policies needed to enforce Impact Level 5 Isolation Requirements.

## URL 

Repo URL: https://github.com/adamdost-msft/azure-policy-il5

## Required Pre-Insatlled Binaries
1. Terraform-Docs
2. Terraform
3. InfraCost (Can be disabled/removed)

````bash
git clone https://github.com/adamdost-msft/azure-policy-il5
make
````

The MakeFile is fairly barebones and is intended to help you jumpstart and evaluting baseline Azure Policies that all teams must adhere to unless they have an exception to it. At this time the Modules only create "Definitions" and do not do policy assignments onto your subscription. That is an action better reserved for when your cyber teams concur that the policies in place will meet the baseline configuration required. At a high level we are performing the following Azure Policies onto the environment.

1. Azure Container Registry
    * Audit Private Endpoints existence
    * Deny creation of the resoruce without a "BYOK"/"Customer Managed Key"
    * Deny the ability to allow public access to the resource over its public interface
1. Azure Storage
    * Audit Private Endpoints existence
    * Deny creation of the resoruce without a "BYOK"/"Customer Managed Key"
    * Deny the ability to allow public access to the resource over its public interface

Private Endpoints are a tricky one to enforce here. Because Private Endpoints are not tied directly to the initial deployment of the Azure resource it will always fail and deny the creation of ACR or Storage because it doesn't deploy as part of the baseline Azure resource if set to "Deny". Therefore you must set the policy to "Audit" specifically so that the resources can be deployed as part of a tiered deployment (Base + PE). You cannot deploy the PE as part of the base deployment for Storage and Container Registry.

Documentation can be found in each modules folders as "README.MD" adn the intent is to eventually deliver a full repository that mirrors what a Cyber Team in DOD would like to see as part of each Azure enviornment. A major area to focus Azure Policies around is core services that hold data at rest (Storage/Acr/OS Disks) and ensuring that the required encryption configurations are common throughout the environment. Resources like Azure Container Registry are limited in how they can flip/flop between CMK & PMK.

My recommendation is you leverage this Makefile and use it as reference for integrating this deployment into a larger pipeline for how you manage Azure Policy State inside of your Azure environment. This is simply built to help kick the tires and get an initial MVP out to your Azure Environments to assess the health of your Azure resources for later remediation & continous assurance that all resources no matter what the deployment method follow the same requirements.
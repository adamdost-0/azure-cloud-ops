---
title: "Securing my IaC with Checkmarx's KICS"
categories:
  - azure
tags:
  - security
---

## What is KICS?

[Source](https://docs.kics.io/latest/)
>Find security vulnerabilities, compliance issues, and infrastructure misconfigurations early in the development cycle of your infrastructure-as-code with KICS by Checkmarx.

>KICS stands for Keeping Infrastructure as Code Secure, it is open source and is a must-have for any cloud native project.

TL;DR Static Code Analysis for IaC that does not cost you a dime to procure

## Why is it important? 

I can write amazing automation for customers day in and day out for them to field into operations the moment it shows up in their Git Repo. However outside of Azure Policy I don't have many resources to check and make sure the IaC itself is clean and doesn't have anything like a hardcoded password or token. That's where KICS comes in to provide my customers the ability to validate the code and not rely on past performance or anything that isn't independently verifiable. One of the most basic exercises is credential scanning and validating that there are no cleartext credentials stored into the repo. You can review on their website the full list of queries that it does on ARM Templates. 

## When to use it?

The tool itself is executed at runtime only and runs inside of WSL2 so running it locally is definitely possible. There are also sample [pipeline scripts](https://docs.kics.io/latest/integrations/) that can help you get it into Azure Pipelines or GitHub so that each time you do a push to your features branch it'll run on the targeted files you need scanned. 

## Where to use it?


One Limitation is that at the time of this blog post KICS can only scan ARM Template's and not Bicep Files so you will need to build your Bicep Files into ARM Templates for the scan to work. Your requirements will define this however if you're building out Bicep Modules and referencing them in your main.bicep file it's best to run KICS on the Module's itself to generate a report for then one on the solution you're building based off of the module. The following mermaid-js outline shows one implementation method

![Rendered File Structure](assets\images\bicep-mermaid-output.svg)


````mermaid-js
graph LR
    root[src] --> a[bicep]
    a --> 1[bicepModules]
    a --> 2[solutions] 
    subgraph 2g[Bicep Solutions Folder]
    2 --> 3[Solution.bicep] --> 4[Code-Scan] --> 5[results.json]
    end

    subgraph 1g[All Bicep modules]
    1 --> 11[acrModule] --> 11a[acr.bicep]
    11 --> 11b[Code-Scan] --> 11c[results.json]
    1 --> 12[vmModule] --> 12a[vm.bicep]
    12 --> 12b[Code-Scan]  --> 12c[results.json]
    end
````

A sample script to execute the scan is the following 

````powershell
<#
.SYNOPSIS
    A quick & dirty script to execute a bicep build & Checkmarx scan


.PARAMETER filePath
    The filePath Paramter is used to define what FOLDER you are looking to have the scanner mount into the container for scanning

.PARAMETER bicepFileName
    The name of the bicep file that will be converted to ARM for KICS to scan it with 
    

.EXAMPLE
    Example syntax for running the script or function
    PS C:\> .\powershell\Scan-Bicep.ps1 -filePath C:\Users\adost\OneDrive\Desktop\cloudOps\azure-cloud-ops\bicep\domainController -bicepFileName dc.bicep

.NOTES
    Filename: Scan-Iac.ps1
    Author: Adam Dost
    Modified date: 2022-03-20
    Version 1.0 - Initial public release
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [String]
    $filePath,
    [Parameter(Mandatory=$true)]
    [string]
    $bicepFileName
)

## Convert Bicep to ARM
bicep build ${FilePath}/${bicepFileName} --outfile main.json
## Run the KICS Scan and create a results folder to dump all possible report formats
docker run -v ${FilePath}:/path checkmarx/kics:debian kics scan `
        --ci `
        -p "/path" `
        -o "/path/results" `
        -t "AzureResourceManager" `
        --report-formats all `
        --cloud-provider azure 
````

## Who benefits from this?

Your customer is the one that will net the best results from this because it provides them an artifact to evaluate the current state of your IaC and it's reusable across cloud providers giving them the assurance that they do not need to create unicorn processes for just a single cloud provider. KICS can output several different file formats (SARIF/html/junit/pdf/json/sonarqube) and with something like Azure DevOps Pipelines you can have that publish as an artifact for review and fail the pipeline if HIGH's show up. 

Go forth and **K**eep your **I**aC **S**ecure before someone finds a way to exploit it! You can find a sample result scan from my dc.bicep scan [here!](https://github.com/adamdost-msft/azure-cloud-ops/tree/main/bicep/domainController/results)

*Disclaimer: I do not work for Checkmarx however I do work at Microsoft!*
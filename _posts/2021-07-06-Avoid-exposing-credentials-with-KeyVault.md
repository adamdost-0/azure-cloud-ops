---
title: "Avoid exposing credentials with Azure KeyVault!"
categories:
  - azure
tags:
  - devsecops
---

When deploying a Virtual Machine into Azure you need to provide a local username and password on first boot prior to it joining a domain. When writing scalable Infrastructure as Code for environments small or large you should do as best to ensure you have **zero** references to anything like a username or password. This allows you to reuse your IaC in various enviornments and ensure that the credentials for the environment aren't exposed in some log or template at all. Let's use Azure Resource Manager to show how it's possible to take a keyvault **secret** value and pass it along for a VM template.

````json

    "AzureVMUserName": {
        "reference": {
            "keyVault": {
                "id": "/subscriptions/{SUBSCRIPTION-GUID/{RESOURCE-GROUP-NAME}/Microsoft.KeyVault/vaults/{KEYVAULT-NAME}"
            }
            "secretName": "{SECRET-NAME-IN-KEYVAULT}"
        }
    },
    "AzureVMPassword": {
        "reference": {
            "keyVault": {
                "id": "/subscriptions/{SUBSCRIPTION-GUID/{RESOURCE-GROUP-NAME}/Microsoft.KeyVault/vaults/{KEYVAULT-NAME}"
            }
            "secretName": "{SECRET-NAME-IN-KEYVAULT}"
        }
    }
````

Last but not least ensure that your Service Principal has the ability to **read** the secret values you are referencing. Now **all** delpoyments that leverage this code snippet and remove any need to know the credentials of the VM in question. 

````json
      "osProfile": {
          "adminUsername": "[parameters('AzureVMUserName')]",
          "adminPassword": "[parameters('AzureVMPassword')]"
        },
````

Azure KeyVault can also host the string for your SSH Public Key for authentication for Linux enviornment's so you can securely connect to them as well. Simply change the keyvault reference to what your SSH Key is!

Take a look at the [Azure public services by audit scope](https://docs.microsoft.com/en-us/azure/azure-government/compliance/azure-services-in-fedramp-auditscope#azure-public-services-by-audit-scope) page to see how Key Vault can meet your complaince requirements for storing and managing secrets!

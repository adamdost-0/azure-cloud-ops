---
title: "How do I isolate a VM in Azure Government? EZ"
categories:
  - azure
tags:
  - sysadmin
---

Working with the Department of Defense (DoD) comes with the regulatory requirements that are in place to ensure that they can operate. As the DoD continues to embrace new commercial solutions into their business it must adhere to their standards. If you work on the Microsoft Cloud you are most likely very familiar with [this page](https://docs.microsoft.com/en-us/azure/azure-government/documentation-government-impact-level-5). Let's try to take the guidance from this page and deploy a basic virtual machine from it.

When building a VM there are several "requirements" tied to building one. First is the network, second is the storage and third is the compute sku. Let's breakdown each piece....


## Azure Dedicated Hosts

To keep it quick and simple you define a Host Group and have Hosts live inside of those groups. The parent (Host Group) is where you define certain policies for your dedicated hosts such as your Availability Zone Requirements and your fault domain requirements. You then assign "Dedicated hosts" to these groups. From within these Dedicated Hosts you can define how you assign each VM to each host and what instances go in X/Y/Z. The below code snippet will deploy 

1. Host Group
2. Host (The Blade itself)

### WARNING | BY DEPLOYING THIS YOU WILL INCUR CHARGES ON YOUR SUBSCRIPTION. CHECK OUT AZURE CALCULATOR AND REACH OUT TO YOUR MSFT REP TO GET A QUOTE TO ENSURE YOU'RE NOT GOING TO BURN THROUGH THIS MONTHS BUDGET



````bicep
param regionPrefix string = 'GV'
param resourcePrefix string = 'AZ-${regionPrefix}-'
param dedicatedHostGrp string = '${resourcePrefix}DHOST-GRP-01'
param dedicatedHosts string = '${resourcePrefix}DHOST-HSTS-01'
param skuName string = 'DSv3-Type3'

resource hostGroup 'Microsoft.Compute/hostGroups@2021-04-01' = {
  name: dedicatedHostGrp
  location: resourceGroup().location
  properties: {
    platformFaultDomainCount: 1 
  }
}

resource dedicatedHostsConfig 'Microsoft.Compute/hostGroups/hosts@2021-04-01' = {
  parent: hostGroup
  name: dedicatedHosts
  location: resourceGroup().location
  sku: {
    name: skuName
  }
  properties: {
    autoReplaceOnFailure: true
    licenseType: 'Windows_Server_Hybrid' // PLEASE USE YOUR ENTITLEMENTS THAT YOU HAVE ALREADY PAID FOR
  }
}


````


````bash
az deployment group create --resource-group 'AZ-APP-01' --template-file './bicep/domainController/dedicatedhost.bicep'
````
From here you will see two resources created in your subscription. Take a look at the "Host" blade and you'll see how much VM Capacity is **reserved** for you on this blade to deploy to. You can mix/match various SKU Sizes as well. 

### Disk Encryption

Next we move onto the OS Disks. We need to ensure that the storage that we leverage for these compute resources meets the same level of encryption. This can be done via BitLocker or dm-crypt. Before proceeding further you need to seriously read up on [Disk Encryption](https://docs.microsoft.com/en-us/azure/virtual-machines/disk-encryption-overview) on Azure and ensure you understand what is/isn't supported as encryption of VM's can get tricky depending on what you encrypt if you go down the OS level encryption and not the server side encryption. In this blog we will be doing the Server Side encryption. Let's do an exercise to deploy a Windows Server 2019 VM and Encrypt the Disk with an Azure Key Vault hosted encryption key.

Here is a code snippet for creating an Azure Key Vault, Key and Disk encryption set that will use said key to encrpyt the disk.

````bicep
resource premiumKeyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: '${resourcePrefix}KVT-IL5-01'
  location: resourceGroup().location
  properties: {
    sku: {
      family: 'A'
      name: 'premium'
    }
    enableRbacAuthorization: false
    enablePurgeProtection: false
    enableSoftDelete: false
    tenantId: subscription().tenantId
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: '63c0cb60-77ee-481c-a970-18125482412f' // This is the object id of the user that you created in the Azure Portal
        permissions: {
          secrets: [
            'all'
          ]
          keys: [
            'all'
          ]
        }
      }
    ]
  }
}

resource adeKey 'Microsoft.KeyVault/vaults/keys@2019-09-01' = {
  parent: premiumKeyVault
  name: '${resourcePrefix}KVT-IL5-01-ADE-01'
  properties: {
    kty: 'RSA'
    keySize: 2048
    keyOps: [
      'encrypt'
      'decrypt'
      'sign'
      'verify'
      'wrapKey'
      'unwrapKey'
    ]
  }
}

resource diskEncryptionSet 'Microsoft.Compute/diskEncryptionSets@2021-04-01' = {
  name: '${resourcePrefix}DSET-01'
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    activeKey: {
      keyUrl: adeKey.properties.keyUriWithVersion
      sourceVault: {
        id: premiumKeyVault.id
      }
    }
  }
}

resource diskEncryptionSetAKVPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2021-04-01-preview' = {
  name: '${premiumKeyVault.name}/add'
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: diskEncryptionSet.identity.principalId
        permissions: {
          keys: [
            'get'
            'wrapKey'
            'unwrapKey'
          ]
        }
      }
    ]
  }
}


````

What this will do is create a Key Vault, Key and Disk Encryption Set. The Disk Encryption Set will use the Key Vault to create a new Key that will be used to encrypt the disk. The Disk Encryption Set will then be assigned to the VM. You must give the Disk Encryption set 3 roles for the "Key" command in Azure Key Vault for it to pull what is needed. 


### Compute Deployment

Now that you've created the resources you need to deploy your isolated workload it's time to deploy the VM. As part of the VM Deployment it will leverage the previously created resources

1. Dedicated Host Group to pull Compute from
2. Azure Premium Key Vault (Hardware Security Modules backed)
3. Disk Encryption Set which uses an Azure Key Vault Key to encrypt disks with a Customer-Managed Key.

Let's deploy the entire stack in a single deployment. Once the deployment is complete head on over to the resource visualizer and you'll see how each piece of the deployment builds on each other from the virtual network to the key vault. You can find the full template [here](https://github.com/adamdost-0/azure-cloud-ops/blob/main/bicep/domainController/dedicatedhost.bicep)

````bicep
param regionPrefix string = 'GV'
param resourcePrefix string = 'AZ-${regionPrefix}-'
param dedicatedHostGrp string = '${resourcePrefix}DHOST-GRP-01'
param dedicatedHosts string = '${resourcePrefix}DHOST-HSTS-01'
param skuName string = 'DSv3-Type2'
param vmSKU string = 'Standard_D4s_v3'
param vmUserName string = 'azureadminuser'

resource hostGroup 'Microsoft.Compute/hostGroups@2021-04-01' = {
  name: dedicatedHostGrp
  location: resourceGroup().location
  properties: {
    platformFaultDomainCount: 1
    supportAutomaticPlacement: true
  }
}

resource dedicatedHostsConfig 'Microsoft.Compute/hostGroups/hosts@2021-04-01' = {
  parent: hostGroup
  name: dedicatedHosts
  location: resourceGroup().location
  sku: {
    name: skuName
  }
  properties: {
    autoReplaceOnFailure: true
    licenseType: 'Windows_Server_Hybrid'
  }
}

// Create a network and subnet

resource vNet 'Microsoft.Network/virtualNetworks@2021-03-01' = {
  name: '${resourcePrefix}VNT-01'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/24'
      ]
    }
  }
}

resource subnet1 'Microsoft.Network/virtualNetworks/subnets@2021-03-01' = {
  parent: vNet
  name: '${resourcePrefix}SUBNET-01'
  properties: {
    addressPrefix: '10.0.0.0/27'
  }
}

// Create a network interface card

resource nic 'Microsoft.Network/networkInterfaces@2021-03-01' = {
  name: '${resourcePrefix}NIC-01'
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: '${resourcePrefix}IPCONFIG-01'
        properties: {
          privateIPAddress: '10.0.0.10'
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: subnet1.id
          }
        }
      }
    ]
  }
}

// Create a premium key vault

resource premiumKeyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: '${resourcePrefix}KVT-IL5-01'
  location: resourceGroup().location
  properties: {
    sku: {
      family: 'A'
      name: 'premium'
    }
    enableRbacAuthorization: false
    //enablePurgeProtection: false
    //enableSoftDelete: false
    tenantId: subscription().tenantId
    enabledForDeployment: true
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: '63c0cb60-77ee-481c-a970-18125482412f' // CHANGE THIS TO YOUR 
        permissions: {
          secrets: [
            'all'
          ]
          keys: [
            'all'
          ]
        }
      }
    ]
  }
}

resource adeKey 'Microsoft.KeyVault/vaults/keys@2019-09-01' = {
  parent: premiumKeyVault
  name: '${resourcePrefix}KVT-IL5-01-ADE-01'
  properties: {
    kty: 'RSA'
    keySize: 2048
    keyOps: [
      'encrypt'
      'decrypt'
      'sign'
      'verify'
      'wrapKey'
      'unwrapKey'
    ]
  }
}

resource diskEncryptionSet 'Microsoft.Compute/diskEncryptionSets@2021-04-01' = {
  name: '${resourcePrefix}DSET-01'
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    activeKey: {
      keyUrl: adeKey.properties.keyUriWithVersion
      sourceVault: {
        id: premiumKeyVault.id
      }
    }
  }
}

resource diskEncryptionSetAKVPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2021-04-01-preview' = {
  name: '${premiumKeyVault.name}/add'
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: diskEncryptionSet.identity.principalId
        permissions: {
          keys: [
            'get'
            'wrapKey'
            'unwrapKey'
          ]
        }
      }
    ]
  }
}

// Create a virtual machine 

resource win19VM 'Microsoft.Compute/virtualMachines@2021-04-01' = {
  name: '${resourcePrefix}VM-01'
  location: resourceGroup().location
  properties: {
    hardwareProfile: {
      vmSize: vmSKU
    }
    hostGroup:{
      id: hostGroup.id
    }
    osProfile: {
      computerName: '${resourcePrefix}VM-01'
      adminUsername: vmUserName
      adminPassword: 'pleaseChangeThisIwillCryIfyoudoNotokthankyouBye'
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
      }
    }
    networkProfile: {

      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: '${resourcePrefix}VM-OS-01'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        diskSizeGB: 256
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
          diskEncryptionSet: {
            id: diskEncryptionSet.id
          }
        }
      }
    }
  }
}

````

[Here's the entire stack!](https://github.com/adamdost-0/azure-cloud-ops/blob/b2fbb8e9d3b0a65fdfd43d1aa5a0865ddea5b754/assets/images/image.png)

That's all for now! Thank you for reading and good luck to those deploying isolated workloads in Azure! 


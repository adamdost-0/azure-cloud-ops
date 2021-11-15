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
        objectId: '63c0cb60-77ee-481c-a970-18125482412f'
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
      adminPassword: '1qaz!QAZ1qaz!QAZ'
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


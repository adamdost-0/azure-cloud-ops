param dcName string = 'fogone.xyz'
param dcAdmin string = 'ccefogoneadmin'
param dcAdminPassword string = newGuid()
param orgName string = 'FOGONE'

resource dcAVS 'Microsoft.Compute/availabilitySets@2020-12-01' = {
  name: '${orgName}-AVS-01'
  location: resourceGroup().location
  properties: {
    platformFaultDomainCount: 2
    platformUpdateDomainCount: 2
  }
  sku: {
    name: 'Aligned'
  }
}

resource fogoneVNET 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: '${orgName}-VNET-01'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.100.0.0/24'
      ]
    }
    subnets: [
      {
        name: '${orgName}-SVC-SNT-01'
        properties: {
          addressPrefix: '10.100.0.0/27'
        }
      }
      {
        name: '${orgName}-DMZ-SNT-01'
        properties: {
          addressPrefix: '10.100.0.32/27'
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.100.0.64/27'
        }
      }
    ]
  }
}

resource dcNIC 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: '${orgName}-NIC-01'
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: '${orgName}-IPC'
        properties: {
          subnet: {
            id: fogoneVNET.properties.subnets[0].id
          }
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.100.0.10'
        }
      }
    ]
  }
}

resource dcVM 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: '${orgName}-DC-01'
  location: resourceGroup().location
  properties: {
    availabilitySet: {
      id: dcAVS.id
    }
    hardwareProfile: {
      vmSize: 'Standard_A2_v2'
    }
    osProfile: {
      computerName: '${orgName}-DC-01'
      adminUsername: dcAdmin
      adminPassword: dcAdminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: '${orgName}-OS-01'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: dcNIC.id
        }
      ]
    }
  }
}

resource dscStorageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: toLower('${orgName}dscstg')
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: true
  }
   
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = {
  name: '${dscStorageAccount.name}/default/dscfiles'
  properties: {
    publicAccess: 'Container'
  }
}

resource aaaDsc 'Microsoft.Automation/automationAccounts@2021-06-22' = {
  name: '${orgName}-AAA-01'
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'Basic'
    }
  }
}

resource vmExtension 'Microsoft.Compute/virtualMachines/extensions@2021-04-01' = {
  name: '${dcVM.name}/PromoteDC'
  location: resourceGroup().location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.7'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        'https://fogonedscstg.blob.core.usgovcloudapi.net/dscfiles/CreateNewADForest.ps1'
      ]
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File CreateNewADForest.ps1 '
    }
  }
}

resource pip 'Microsoft.Network/publicIPAddresses@2021-03-01' = {
  name: '${orgName}-PIP-01'
  location: resourceGroup().location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
}

resource guac 'Microsoft.Network/bastionHosts@2021-03-01' = {
  name: '${orgName}-GUAC-01'
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: '${orgName}-IPC'
        properties: {
          subnet: {
            id: fogoneVNET.properties.subnets[2].id
          }
          publicIPAddress: {
            id: pip.id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}


resource adfsNIC 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: '${orgName}-NIC-02'
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: '${orgName}-IPC'
        properties: {
          subnet: {
            id: fogoneVNET.properties.subnets[0].id
          }
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.100.0.11'
        }
      }
    ]
     dnsSettings: {
      dnsServers: [
        dcNIC.properties.ipConfigurations[0].properties.privateIPAddress
      ]
     }
  }
}

resource adfsVM 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: '${orgName}-ADFS-01'
  location: resourceGroup().location
  properties: {
    availabilitySet: {
      id: dcAVS.id
    }
    hardwareProfile: {
      vmSize: 'Standard_A2_v2'
    }
    osProfile: {
      computerName: '${orgName}-ADFS-01'
      adminUsername: dcAdmin
      adminPassword: dcAdminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: '${orgName}-ADFS-OS-01'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: adfsNIC.id
        }
      ]
    }
  }
}

resource adfsDomainJoin 'Microsoft.Compute/virtualMachines/extensions@2021-03-01' = {
  parent: adfsVM
  name: 'joindomain'
  location: resourceGroup().location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'JsonADDomainExtension'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      name: 'fogone.xyz'
      user: 'fogone.xyz\\ccefogoneadmin'
      restart: true
    }
    protectedSettings: {
      Password: '1qaz!QAZ1qaz!QAZ'
    }
  }
}



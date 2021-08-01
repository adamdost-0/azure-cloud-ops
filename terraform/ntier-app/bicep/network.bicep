@description('NAME OF VNET THAT HOSTS THE SUBNET')
param vnetName string = 'AZ-EUS-DOD-AF-CCE-WEAPS-L-IL6-VNET-01'
@description('NAME OF RESOURCE GROUP HOSTING THE VNET')
param vnetRgp string = 'NET-RGP-01'


resource plinkSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: '${vnetName}/PLINK-01'
  properties: {
    addressPrefix: '10.0.0.32/27'
    privateEndpointNetworkPolicies: 'Disabled'
  }
}

resource vnetExternal 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetRgp)
}

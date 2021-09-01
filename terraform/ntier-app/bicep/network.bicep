@description('NAME OF VNET THAT HOSTS THE SUBNET')
param vnetName string = 'AZ-EUS-VNET-02'
@description('NAME OF RESOURCE GROUP HOSTING THE VNET')
param vnetRgp string = 'NET-RGP-02'

param privateLinkSubnetName string = 'PLINK-01'
param privateLinkSubnetAddressPrefix string = '10.0.0.0/27'

param appSvcSubnetName string = 'vnetRegionalPeering'
param appSvcSubnetPrefix string = '10.0.0.32/27'
var plinkSqlDnsZone = environment().suffixes.sqlServerHostname
var plinkRdisDnsZone = 'privatelink.redis.cache.windows.net'
var plinkStgDnsZone = environment().suffixes.storage

resource plinkSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: '${vnetName}/${privateLinkSubnetName}'
  properties: {
    addressPrefix: privateLinkSubnetAddressPrefix
    privateEndpointNetworkPolicies: 'Disabled'
  }
  
  dependsOn: [
    vnetCreate
  ]
}

resource vnetPeeringSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: '${vnetName}/${appSvcSubnetName}'
  properties: {
    addressPrefix: appSvcSubnetPrefix
    privateEndpointNetworkPolicies: 'Disabled'
    delegations: [
      {
        id: 'webapp'
        properties: {
          serviceName: 'Microsoft.Web/serverFarms'
        }
        name: 'webapp'
      }
    ]
 
  }
  dependsOn: [
    plinkSubnet
  ]
}

resource vnetCreate 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: vnetName
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/24'
      ]
    }
  }
}

/*

resource vnetExternal 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetRgp)
}
*/

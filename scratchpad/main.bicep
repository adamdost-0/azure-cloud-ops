/* Grab Virtual Network Information */

/* Grab Virtual Network Resource Group Name */
param vnetResourceGroupName string
/* Grab Virtual Network Name */
param vnetName string
/* Grab Virtual Network Subnet Name */
param vnetSubnetName string
/* Generate unique timestamp */
param timestamp string = utcNow()


/* Virtual Machine Name */
param vmName string
/* Virtual Machine Resource Group Target */
param vmResourceGroupName string

targetScope = 'subscription'

/* Grab Virtual Network Resource Information to verify in ARM that it Exists */
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-08-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetResourceGroupName)
}

/* Grab Virtual Network Subnet Resource Information to verify in ARM that it Exists */
resource virtualNetworkSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' existing = {
  name: vnetSubnetName
  parent: virtualNetwork
}

/* Grab Virtual Machine Resource Group Information to verify in ARM that it Exists */
resource vmResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' existing = {
  name: vmResourceGroupName
}

/* Deploy Network Interface Card */
module nic 'modules/nic/deploy.bicep' = {
  name: '${timestamp}-${vmName}-nic'
  scope: vmResourceGroup
  params: {
    resourceGroupLocation: vmResourceGroup.location 
    subnetId: virtualNetworkSubnet.id
    vmName: vmName
  }
}


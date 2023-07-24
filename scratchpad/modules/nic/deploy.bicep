/* Virtual Network Subnet ID for NIC Assignment */
param subnetId string
/* Resource Group Location for NIC Assignment */
param resourceGroupLocation string
/* Virtual Machine Name for NIC Assignment */
param vmName string

/* Build NIC Name based off of VM Name */
var nicName = '${vmName}-nic'
/* Build IP Config Name based off of VM Name */
var ipConfigName = '${vmName}-ip-config'

/* Create Network Interface Card using the above referenced information*/
resource nic 'Microsoft.Network/networkInterfaces@2018-11-01' = {
  name: nicName
  location: resourceGroupLocation
  properties: {
    ipConfigurations: [
      {
        name: ipConfigName
        properties: {
          subnet: {
            id: subnetId
          }
          /* 
          This is bad practice to do dynamic NIC assignment. For production information
          systems the MSFT CSP Team recommends using Static IP Allocation with known convention
          ranges. Subnets can be carved for specific use cases and then the IP Address can be
          assigned to the NIC. This is a best practice for production systems. For this reference we will do dynamic
          assignment. We are going with MVP Pilot approach for this reference.
          */
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}



/* Output the NIC ID for use in other resources */
output nicId string = nic.id
/* Output the NIC Name for use in other resources */
output nicName string = nic.name

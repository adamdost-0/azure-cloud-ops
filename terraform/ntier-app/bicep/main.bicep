@description('DOCKER IMAGE AND TAG')
param dockerImageAndTag string = 'app/nginx:latest'

@description('COMMON BASELINE PREFIX FOR ALL AZURE RESOURCES CREATED. COMMON NAMING CONVENTION HELPS INVENTORY ASSESSMENTS AND UNDERSTANDING WHERE RESOURCES ARE STORED.')
param cmn_prefix string = 'AZ-${region_prefix}-${appName}-${env}-${impact}-'

param accessPolicies array = [
  {
    tenantId: tenant
    objectId: 'c06797b1-f6a0-4514-a9e9-e9f4964dec1c' // replace with your objectId
    permissions: {
      keys: [
        'Get'
        'List'
        'Update'
        'Create'
        'Import'
        'Delete'
        'Recover'
        'Backup'
        'Restore'
      ]
      secrets: [
        'Get'
        'List'
        'Set'
        'Delete'
        'Recover'
        'Backup'
        'Restore'
      ]
      certificates: [
        'Get'
        'List'
        'Update'
        'Create'
        'Import'
        'Delete'
        'Recover'
        'Backup'
        'Restore'
        'ManageContacts'
        'ManageIssuers'
        'GetIssuers'
        'ListIssuers'
        'SetIssuers'
        'DeleteIssuers'
      ]
    }
  }
]
@description('NAME OF KEYVAULT WHERE ALL AZURE RESOURCE CREDENTIALS WILL BE STORED AND TREATED AS THE SOURCE OF TRUTH FOR ALL CREDENTIALS IN THE ENVIRONMENT. HYPHENS ARE NOT ALLOWED IN THE URL NAME. ENFORCED BY AZURE FABRIC.')
param kvt_name string = '${region_prefix}${appName}${impact}KVT'

@description('DEFINE THE APPLICATION NAME')
param appName string = 'MSFT'

@allowed([
  'IL2'
  'IL4'
  'IL5'
  'IL6'
])
@description('DEFINE THE IMPACT LEVEL OF THE APPLICATION')
param impact string = 'IL2'

@allowed([
  'L'
  'D'
  'T'
  'P'
  'X'
])
param env string = 'L'

@description('DEFINE THE REGION LOCATION')
@allowed([
  'EUS'
  'EUS2'
  'GV'
  'GT'
  'DE'
  'DC'
  'SE'
  'SC'
])
param region_prefix string = 'EUS'

/* Booleans for ensuring Key Vault can be used for something besides a secret store */
param enabledForDeployment bool = true
param enabledForDiskEncryption bool = true
param enabledForTemplateDeployment bool = true

@description('DEFINE THE KEY VAULT SKU FOR DEPLOYMENT')
param kvtSku string = 'Standard' 

@description('GET THE TENANT ID FROM THE ARM FABRIC SO THAT THIS REMAINS AS PORTABLE AS POSSIBLE')
param tenant string = subscription().tenantId


@description('DEFINE A NAME FOR THE AZURE OBJECT')
param appSvcName string = '${cmn_prefix}APP-01'

@description('DEFINE A NAME FOR THE AZURE OBJECT')
param planName string = '${cmn_prefix}HPN-01'

@description('DEFINE THE NATIVE SQL USER NAME IF NOT USING AAD AUTHENTICATION')
param sql_user string = 'sql_db_admin'

@description('DEFINE THE CONTAINER REGISTRY SKU, PREMIUM IF NEEDED, OTHERWISE STANDARD')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param acr_tier string = 'Premium'

@description('DEFINE A URL-FRIENDLY ACR NAME SO THAT THIS CAN BE DEPLOYED')
param acr_server_name string = '${region_prefix}${appName}${env}${impact}ACR'

@secure()
@description('CREATE A UNIQUE GUID AND STORE IN KEYVAULT AND USE AS SQL SERVER ADMIN PASSWORD IF AAD AUTHENTICATION WILL NOT BE USED AS THE APPS MAIN FORM OF AUTHN')
param sql_secret string = newGuid()


@description('CREATE A SQL DB WITH THE NAME BELOW')
param db_name string = 'db_1'
param second_db_name string = 'db_2'

@description('ASSIGN THE FOLLOWING TAGS TO EVERY AZURE RESOURCE SO A COMMON BASELINE IS MET')
param tags object = {
  'Cloud Service Provider' : ''
  'Account' : ''
  'Department': ''
  'Program' : ''
  'Functional' : ''
  'Applicatoin' : ''
}

@description('PRIVATE LINK SUBNET REFERENCE ID')
param subnetName string = 'PLINK-01'

@description('REGION VNET PEERING SUBNET REFERENCE ID')
param delegatedSubnet string = 'vnetRegionalPeering'

@description('NAME OF VNET THAT HOSTS THE SUBNET')
param vnetName string = 'AZ-EUS-VNET-01'

@description('NAME OF RESOURCE GROUP HOSTING THE VNET')
param vnetRgp string = 'NET-RGP-02'



/* Variables for deployment */
/* Private DNS Zones for SQL, Redis and Storage */

var plinkSqlDnsZone = environment().suffixes.sqlServerHostname
var plinkRdisDnsZone = 'privatelink.redis.cache.windows.net'
var plinkStgDnsZone = environment().suffixes.storage

/* Azure Reference ID for the external subnet for PrivateLinks */
var privateLinkSubnetRef = '${vnetExternal.id}/subnets/${subnetName}'

/* Azure Reference ID for the external sbunet for vnet Regional Peering */
var vnetRegionalPeering = '${vnetExternal.id}/subnets/${delegatedSubnet}'

/* Explicit definition of ensuring all services use TLS 1.2 */
var minTlsVersion = '1.2' 

/* Grab the Redis Primary Key from the Azure Fabric to build the follow up connection String */
var redisPrimaryKey = listKeys(redis.id,redis.apiVersion).primaryKey

/* Build the Redis connection string so it can be passed an env variable to the docker container */
var redisConnectionString = toLower('${redis.properties.hostName}:${redis.properties.sslPort},password=${redisPrimaryKey},ssl=True,aboutConnection=False,,sslprotocols=tls12')

/* Grab the ACR admin password #1 from the vault so it can be passed into the App Service for continous deployment */
var acr_pwd = listCredentials(container_registry.id,container_registry.apiVersion).passwords[0].value

/* Build the Azure SQL Connection String in a repeatable fashion so that any and all SQL DB credentials can be assigned to KVT as a secret for deployment */
var sql_conn_string = 'Server=tcp:${sql_server.properties.fullyQualifiedDomainName},1433:Initial Catalog=${db_name};Persist Security Info=False;User ID=${sql_user};Password=${sql_secret};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'



// Deployment Guide
/*

1. Create Redis Cache
2. Create Azure SQL Server
3. Create Azure SQL DB
4. Store Azure SQL URL, User, Pass, DB ConnString, Redis Cache URL, Redis Cache ConnString
5. Create Azure WebApp 
6. Create Azure WebApp MSI to Assign to KVT
7. Create Azure App Service Config 
8. Drop Private Links into the VNET so that the resources are accessible insdie of the VNET Per regional vnet integration

*/


/* Create Redis Cache */

resource redis 'Microsoft.Cache/redis@2020-12-01' = {
  name: '${cmn_prefix}RDIS-01'
  tags: tags
  location: resourceGroup().location
  properties: {
    minimumTlsVersion: minTlsVersion
    sku: {
      capacity: 1
      family: 'C'
      name: 'Basic'
    }
  }
}

/* Create SQL Server AND SQL DB's | Remember to double check the auto tuning settings so you don't burn your entire Azure Commit! */

resource sql_server 'Microsoft.Sql/servers@2021-02-01-preview' = {
  name: '${cmn_prefix}SQL-01'
  tags: tags
  location: resourceGroup().location
  properties: {
    administratorLogin: sql_user
    administratorLoginPassword: sql_secret
    version: '12.0'
    minimalTlsVersion: minTlsVersion
  }
  resource db 'databases' = {
    name: db_name
    location: resourceGroup().location
  }
  resource db2 'databases' = {
    name: second_db_name
    location: resourceGroup().location
  }
}

/* Create an Azure Key Vault to store our secrets and assign assign the object id (myself) with full access to everything inside of it */

resource keyvault 'Microsoft.KeyVault/vaults@2021-04-01-preview' = {
  name: kvt_name
  location: resourceGroup().location
  tags: tags
  properties: {
    tenantId: tenant
    sku: {
      family: 'A'
      name: kvtSku
    }
    accessPolicies: accessPolicies
    enabledForDeployment: enabledForDeployment // There are boolean references
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
  }
}

/* Assign Azure SQL Admin password to DB to KVT */

resource sql_pass_kvt 'Microsoft.KeyVault/vaults/secrets@2020-04-01-preview' = {
  name: '${keyvault.name}/${cmn_prefix}SQL-ADMIN-PWD'
  properties: {
    value: sql_secret
  }
}

/* Assign Azure SQL Admin User to DB to KVT */

resource sql_user_kvt 'Microsoft.KeyVault/vaults/secrets@2020-04-01-preview' = {
  name: '${keyvault.name}/${cmn_prefix}SQL-ADMIN-USR'
  properties: {
    value: sql_user
  }
}

/* Assign root Azure SQL SERVER URI to KVT */

resource sql_kvt_url 'Microsoft.KeyVault/vaults/secrets@2020-04-01-preview' = {
  name: '${keyvault.name}/${cmn_prefix}SQL-URL'
  tags: tags
  properties: {
    value: toLower(sql_server.properties.fullyQualifiedDomainName)
  }
}

/* Assign  Azure SQL SERVER Connection String to KVT */

resource sql_conn_url 'Microsoft.KeyVault/vaults/secrets@2020-04-01-preview' = {
  name: '${keyvault.name}/${cmn_prefix}SQL-CONN-URL'
  tags: tags
  properties: {
    value: sql_conn_string
  }
}

/* Assign Assign Redis Cache URI to KVT */

resource redis_kvt_url 'Microsoft.KeyVault/vaults/secrets@2020-04-01-preview' = {
  name: '${keyvault.name}/${cmn_prefix}RDIS-URL'
  tags: tags
  properties: {
    value: toLower(redis.properties.hostName)
  }
}

/* Assign Assign Redis Cache Connection String to KVT */

resource redis_conn_url 'Microsoft.KeyVault/vaults/secrets@2020-04-01-preview' = {
  name: '${keyvault.name}/${cmn_prefix}RDIS-CONN-URL'
  tags: tags
  properties: {
    value: redisConnectionString
  }
}

/* Create Hosting Plan Server Farm for WebApps to deploy from */
resource hostingPlan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: planName
  location: resourceGroup().location
  properties: {
    reserved: true
    targetWorkerCount: 3
    targetWorkerSizeId: 3
  }
  sku: {
    name: 'P1v2'
    tier: 'Standard'
  }
  kind: 'linux'
  dependsOn: [
    sql_kvt_url
    sql_conn_url
    redis_kvt_url
    sql_server
    sql_pass_kvt
    sql_user_kvt
    redis_conn_url
  ]
}

/* Create Azure WebApp  */

resource site 'microsoft.web/sites@2020-06-01' = {
  name: appSvcName
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true 
    siteConfig: {
      linuxFxVersion: 'DOCKER|${container_registry.properties.loginServer}/${dockerImageAndTag}'
    }
    serverFarmId: hostingPlan.id
  }
  
  dependsOn: [
    acr_admin_pass
    acr_admin_user
    acr_login_server
    sql_kvt_url
    redis_kvt_url
  ]
  /* Integrate the Azure WebApp with the VNET that homes the Private Link Subnet */
  resource virtualNetworkIntegration 'networkConfig@2020-12-01' = {
    name: 'virtualNetwork'
    properties: {
      subnetResourceId: vnetRegionalPeering
      swiftSupported: true
    }    
  }  
}






resource siteSettings 'Microsoft.Web/sites/config@2020-06-01' = {
  parent: site
  name: 'appsettings'
  properties: {
    WEBSITE_DNS_SERVER: '168.63.129.16'
    WEBSITE_VNET_ROUTE_ALL: '1' //Force Tunnels EGRESS Traffic out through the VNET.
    DOCKER_REGISTRY_SERVER_URL: 'https://${container_registry.properties.loginServer}'
    DOCKER_REGISTRY_SERVER_USERNAME: acr_server_name
    DOCKER_REGISTRY_SERVER_PASSWORD: acr_pwd
    WEBSITES_ENABLE_APP_SERVICE_STORAGE: 'false'
    REDIS_CACHE_CONN_STRING: '@Microsoft.KeyVault(SecretUri=${redis_conn_url.properties.secretUri}/)'
    SQL_CONN_STRING: '@Microsoft.KeyVault(SecretUri=${sql_conn_url.properties.secretUri}/)'
    CONTAINER_REGISTRY_URL: '@Microsoft.KeyVault(SecretUri=${acr_admin_user.properties.secretUri}/)'
  }
}



/* Assign Azure WebApp's Managed System Identity to Azure KeyVault for all secret actions (just need GET) */

resource appSvcVaultPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2021-04-01-preview' = {
  name: '${keyvault.name}/add'
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: site.identity.principalId
        permissions: {
          secrets: [
            'get'
          ]
        }
      }
    ]
  }
  
}

/* Create Azure Container Registry  */

resource container_registry 'Microsoft.ContainerRegistry/registries@2019-12-01-preview' = {
  name: acr_server_name
  location: resourceGroup().location
  sku: {
    name: acr_tier
  }
  properties: {
    adminUserEnabled: true
    networkRuleBypassOptions: 'AzureServices'
    publicNetworkAccess: 'Enabled'
  }
  dependsOn: [
    keyvault
  ]
}
/* Assign Azure Container Registry Admin Pass to KVT */
resource acr_admin_pass 'Microsoft.KeyVault/vaults/secrets@2020-04-01-preview' = {
  name: '${keyvault.name}/${cmn_prefix}ACR-PWD'
  properties: {
    value: acr_pwd
  }
  dependsOn: [
    container_registry
  ]
}

/* Assign Azure Container Registry Server URI to Key Vault */
resource acr_login_server 'Microsoft.KeyVault/vaults/secrets@2020-04-01-preview' = {
  name: '${keyvault.name}/${cmn_prefix}ACR-LOGIN-SRV'
  properties: {
    value: container_registry.properties.loginServer
  }
  dependsOn: [
    container_registry
  ]
}

/* Assign Azure Container Registry Admin User to key vault */
resource acr_admin_user 'Microsoft.KeyVault/vaults/secrets@2020-04-01-preview' = {
  name: '${keyvault.name}/${cmn_prefix}ACR-USR'
  properties: {
    value: acr_server_name
  }
  dependsOn: [
    container_registry
  ]
}


/* Reference the remote VNET so that we can target private endpoints into it */

resource vnetExternal 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetRgp)
}

/* Create the SQL Private endpoint in the Private Link Targeted Subnet */

resource plink_sql 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: '${cmn_prefix}SQL-PLINK-01'
  location: resourceGroup().location
  properties: {
    subnet: {
      id: privateLinkSubnetRef
    }
    privateLinkServiceConnections: [
      {
        properties: {
          privateLinkServiceId: sql_server.id
          groupIds: [
            'sqlServer'
          ]
        }
        name: '${cmn_prefix}SQL-PLINK-01'
      }
    ]
  }  
}

/* Create the Redis Cache endpoint in the Private Link targeted Subnet */

resource plink_redis 'Microsoft.Network/privateEndpoints@2021-02-01' = {
  name: '${cmn_prefix}RDIS-PLINK-01'
  location: resourceGroup().location
  properties: {
    subnet: {
      id: privateLinkSubnetRef
    }
    privateLinkServiceConnections: [
      {
        properties: {
          privateLinkServiceId: redis.id
          groupIds: [
            'redisCache'
          ]
        }
        name: '${cmn_prefix}RDIS-PLINK-01'
      }
    ]
  }  
}


resource sqlPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink${plinkSqlDnsZone}'
  location: 'global'
  resource virtualNetworkLinks 'virtualNetworkLinks' = {
    name: 'linkDnsZone2Vnet'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: vnetExternal.id
      }
    }
  }
}

resource cachePrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: plinkRdisDnsZone
  location: 'global'
  resource virtualNetworkLinks 'virtualNetworkLinks' = {
    name: 'linkDnsZone2Vnet'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: vnetExternal.id
      }
    }
  }
}


resource storagePrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.${plinkStgDnsZone}'
  location: 'global'
  resource virtualNetworkLinks 'virtualNetworkLinks' = {
    name: 'linkDnsZone2Vnet'
    location: 'global'
    properties: {
      registrationEnabled: false
      virtualNetwork: {
        id: vnetExternal.id
      }
    }
  }
}


resource sqlZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-07-01' = {
  name: '${plink_sql.name}/mydnsgroupname'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: sqlPrivateDnsZone.id
        }
      }
    ]
  }
}

resource redisZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-07-01' = {
  name: '${plink_redis.name}/mydnsgroupname'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: cachePrivateDnsZone.id
        }
      }
    ]
  }
}


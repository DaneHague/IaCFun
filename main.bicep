// Parameters
param location string = 'UKSouth'
param appServicePlanName string = 'myAppServicePlan111'
param functionApp1Name string = 'testFunctionApp1-xyz123'
param functionApp2Name string = 'testFunctionApp2-xyz123'
param serviceBusNamespaceName string = 'testServiceBusNamespace-xyz123'
param appInsightsName string = 'myAppInsights'
param keyVaultName string = 'testKeyVault-xyz2323'
param storageAccountName string = 'mystorageaccountjj3424'
param aksClusterName string = 'myAKSCluster'
param sshPublicKey string

// App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
    size: 'B1'
    capacity: 1
  }
}

// Function App 1
resource functionApp1 'Microsoft.Web/sites@2022-03-01' = {
    name: functionApp1Name
    location: location
    kind: 'functionapp'
    properties: {
      serverFarmId: appServicePlan.id
      siteConfig: {
        appSettings: [
          {
            name: 'AzureWebJobsStorage'
            value: storageAccount.properties.primaryEndpoints.blob
          }
          {
            name: 'FUNCTIONS_EXTENSION_VERSION'
            value: '~4'
          }
          {
            name: 'FUNCTIONS_WORKER_RUNTIME'
            value: 'dotnet'
          }
        ]
      }
    }
  }
  
  // Function App 2
  resource functionApp2 'Microsoft.Web/sites@2022-03-01' = {
    name: functionApp2Name
    location: location
    kind: 'functionapp'
    properties: {
      serverFarmId: appServicePlan.id
      siteConfig: {
        appSettings: [
          {
            name: 'AzureWebJobsStorage'
            value: storageAccount.properties.primaryEndpoints.blob
          }
          {
            name: 'FUNCTIONS_EXTENSION_VERSION'
            value: '~4'
          }
          {
            name: 'FUNCTIONS_WORKER_RUNTIME'
            value: 'dotnet'
          }
        ]
      }
    }
  }
  
  // Service Bus
  resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2021-11-01' = {
    name: serviceBusNamespaceName
    location: location
    sku: {
      name: 'Standard'
      tier: 'Standard'
    }
  }
  
  // Application Insights
  resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
    name: appInsightsName
    location: location
    kind: 'web'
    properties: {
      Application_Type: 'web'
    }
  }
  
  // Key Vault
  resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
    name: keyVaultName
    location: location
    properties: {
      sku: {
        family: 'A'
        name: 'standard'
      }
      tenantId: subscription().tenantId
      accessPolicies: []
    }
  }
  
  // Storage Account
  resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
    name: storageAccountName
    location: location
    sku: {
      name: 'Standard_LRS'
    }
    kind: 'StorageV2'
  }
  
  // AKS Cluster with Managed Identity
  resource aksCluster 'Microsoft.ContainerService/managedClusters@2023-01-01' = {
    name: aksClusterName
    location: location
    identity: {
      type: 'SystemAssigned'
    }
    properties: {
      dnsPrefix: 'aksdns'
      agentPoolProfiles: [
        {
          name: 'agentpool'
          count: 1
          vmSize: 'Standard_B2s' // Small VM size for testing
          osType: 'Linux'
          mode: 'System'
        }
      ]
      linuxProfile: {
        adminUsername: 'azureuser'
        ssh: {
          publicKeys: [
            {
              keyData: sshPublicKey
            }
          ]
        }
      }
      networkProfile: {
        networkPlugin: 'azure'
      }
    }
  }

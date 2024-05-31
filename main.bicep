targetScope = 'subscription'

/*
------------------
param section
------------------
*/

// ---- param for Common ----
param resourceGroupName string
param resourceGroupLocation string
param myipaddress string

// ---- param for Hub ----
param hubVNet1Name string
param hubVNet1Address string
// VM Subnet
param hubVNet1Subnet1Name string 
param hubVNet1Subnet1Address string
// Private Endpoint Subnet
param hubVNet1Subnet2Name string 
param hubVNet1Subnet2Address string
// DNS Resolver Subnet
param hubVNet1Subnet3Name string
param hubVNet1Subnet3Address string
// VPN Gateway Subnet
param hubVNet1Subnet4Name string
param hubVNet1Subnet4Address string

// ---- param for Onpre VNet1----
// VNet1
param onpreVNet1Name string
param onpreVNet1Address string
// VNet1 - VM Subnet
param onpreVNet1Subnet1Name string 
param onpreVNet1Subnet1Address string
// VNet1 - VPN Gateway Subnet
param onpreVNet1Subnet2Name string
param onpreVNet1Subnet2Address string
// ---- param for Onpre VNet2----
// VNet2
param onpreVNet2Name string
param onpreVNet2Address string
// VNet2 - DNS Server Subnet
param onpreVNet2Subnet1Name string
param onpreVNet2Subnet1Address string
// ---- param for VM on vNet1 ----
param onpreVNet1vm1Name string
param onpreVNet1vm1OSType string
param onpreVNet1vm1pip string
param onpreVNet1vm2Name string
param onpreVNet1vm2OSType string
param onpreVNet1vm2pip string
// ---- param for VM on vNet2 ----
param onpreVNet2vm1Name string
param onpreVNet2vm1OSType string
param onpreVNet2vm1pip string
// ---- param for VM common ----
param vmSizeWindows string
param spotvm string
@secure()
param adminUserName string
@secure()
param adminPassword string

// ---- param for VPN Gateway ----
// Azure VPN Gateway
param hubVPNGWName string
param hubLngName string
// Onpre VPN Gateway
param onpreVPNGWName string
param onpreLngName string
// VPN Connection shared key (PSK)
@secure()
param connectionsharedkey string

/*
------------------
resource section
------------------
*/

resource newRG 'Microsoft.Resources/resourceGroups@2021-04-01' = { 
  name: resourceGroupName 
  location: resourceGroupLocation 
} 

/*
---------------
module section
---------------
*/

// Create Hub Environment (VNet, Subnet, NSG, VPN Gateway, Local Network Gateway)
module HubModule './modules/hubEnv.bicep' = { 
  scope: newRG 
  name: 'CreateHubEnv' 
  params: { 
    location: resourceGroupLocation
    hubVNet1Name: hubVNet1Name
    hubVNet1Address: hubVNet1Address
    hubVNet1Subnet1Name: hubVNet1Subnet1Name
    hubVNet1Subnet1Address: hubVNet1Subnet1Address
    hubVNet1Subnet2Name: hubVNet1Subnet2Name
    hubVNet1Subnet2Address: hubVNet1Subnet2Address
    hubVNet1Subnet3Name: hubVNet1Subnet3Name
    hubVNet1Subnet3Address: hubVNet1Subnet3Address
    hubVNet1Subnet4Name: hubVNet1Subnet4Name
    hubVNet1Subnet4Address: hubVNet1Subnet4Address
    hubVPNGWName: hubVPNGWName
    hubLngName: hubLngName
  } 
}

// Create Onpre Environment (VM-Windows VNet, Subnet, NSG, Vnet Peering, VPN Gateway, Local Network Gateway)
module OnpreModule './modules/onpreEnv.bicep' = { 
  scope: newRG 
  name: 'CreateOnpreEnv' 
  params: { 
    location: resourceGroupLocation
    myipaddress: myipaddress
    onpreVNet1Name: onpreVNet1Name
    onpreVNet1Address: onpreVNet1Address
    onpreVNet1Subnet1Name: onpreVNet1Subnet1Name
    onpreVNet1Subnet1Address: onpreVNet1Subnet1Address
    onpreVNet1Subnet2Name: onpreVNet1Subnet2Name
    onpreVNet1Subnet2Address: onpreVNet1Subnet2Address
    onpreVNet2Name: onpreVNet2Name
    onpreVNet2Address: onpreVNet2Address
    onpreVNet2Subnet1Name: onpreVNet2Subnet1Name
    onpreVNet2Subnet1Address: onpreVNet2Subnet1Address
    onpreVNet1vm1Name: onpreVNet1vm1Name
    onpreVNet1vm1OSType: onpreVNet1vm1OSType
    onpreVNet1vm1pip: onpreVNet1vm1pip
    onpreVNet1vm2Name: onpreVNet1vm2Name
    onpreVNet1vm2OSType: onpreVNet1vm2OSType
    onpreVNet1vm2pip: onpreVNet1vm2pip
    onpreVNet2vm1Name: onpreVNet2vm1Name
    onpreVNet2vm1OSType: onpreVNet2vm1OSType
    onpreVNet2vm1pip: onpreVNet2vm1pip 
    vmSizeWindows: vmSizeWindows
    spotvm: spotvm 
    adminUserName: adminUserName
    adminPassword: adminPassword
    onpreVPNGWName: onpreVPNGWName
    onpreLngName: onpreLngName
  } 
}

// Create Connection for Onpre VPN Gateway and Azure VPN Gateway
module VPNConnectionModule './modules/vpnConnection.bicep' = { 
  scope: newRG 
  name: 'CreateVPNConnection' 
  params: { 
    location: resourceGroupLocation
    hubVPNGWID: HubModule.outputs.hubVPNGWId
    hubLngID: HubModule.outputs.hubLngId
    onpreVPNGWID: OnpreModule.outputs.onpreVPNGWId
    onpreLngID: OnpreModule.outputs.onpreLngId
    connectionsharedkey: connectionsharedkey
  } 
  dependsOn: [
    HubModule
    OnpreModule
  ]
}

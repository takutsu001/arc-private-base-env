/*
------------------
param section
------------------
*/
// Common
param location string
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
// for VPN Gateway
param hubVPNGWName string
param hubLngName string

/*
------------------
var section
------------------
*/
// VM Subnet
var hubVNet1Subnet1 = { 
  name: hubVNet1Subnet1Name 
  properties: { 
    addressPrefix: hubVNet1Subnet1Address
    networkSecurityGroup: {
    id: nsgDefault.id
    }
  }
}
// Private Endpoint Subnet
var hubVNet1Subnet2 = { 
  name: hubVNet1Subnet2Name 
  properties: { 
    addressPrefix: hubVNet1Subnet2Address
    networkSecurityGroup: {
      id: nsgDefault.id
    }
  }
} 
// DNS Resolver Subnet
var hubVNet1Subnet3 = { 
  name: hubVNet1Subnet3Name
  properties: { 
    addressPrefix: hubVNet1Subnet3Address
    networkSecurityGroup: {
      id: nsgDefault.id
    }
  } 
} 
// VPN Gateway Subnet
var hubVNet1Subnet4 = { 
  name: hubVNet1Subnet4Name 
  properties: { 
    addressPrefix: hubVNet1Subnet4Address
  } 
} 

/*
------------------
resource section
------------------
*/

// create network security group for hub vnet
resource nsgDefault 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: 'hub-nsg'
  location: location
  properties: {
  //  securityRules: [
  //    {
  //      name: 'Allow-RDP'
  //      properties: {
  //      description: 'RDP access permission from your own PC.'
  //     protocol: 'TCP'
  //      sourcePortRange: '*'
  //      destinationPortRange: '3389'
  //      sourceAddressPrefix: myipaddress
  //      destinationAddressPrefix: '*'
  //      access: 'Allow'
  //      priority: 1000
  //      direction: 'Inbound'
  //    }
  //  }
  //]
  }
}

// create hubVNet & hubSubnet
resource hubVNet 'Microsoft.Network/virtualNetworks@2021-05-01' = { 
  name: hubVNet1Name 
  location: location 
  properties: { 
    addressSpace: { 
      addressPrefixes: [ 
        hubVNet1Address 
      ] 
    } 
    subnets: [ 
      hubVNet1Subnet1
      hubVNet1Subnet2
      hubVNet1Subnet3
      hubVNet1Subnet4
    ]
  }
  // Get subnet information where VPN Gateway is connected.
  resource hubGatewaySubnet 'subnets' existing = {
    name: hubVNet1Subnet4Name
  }
}

// create public ip address for VPN Gateway
resource hubVPNGWpip 'Microsoft.Network/publicIPAddresses@2022-05-01' = {
  name: '${hubVPNGWName}-pip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

// create VPN Gateway for hub (RouteBased)
resource hubVPNGW 'Microsoft.Network/virtualNetworkGateways@2023-06-01' = {
  name: hubVPNGWName
  location: location
  properties: {
    enablePrivateIpAddress: false
    ipConfigurations: [
      {
        name: '${hubVPNGWName}-ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: hubVPNGWpip.id
          }
          subnet: {
            id: hubVNet::hubGatewaySubnet.id
          }
        }
      }
    ]
    natRules: []
    virtualNetworkGatewayPolicyGroups: []
    enableBgpRouteTranslationForNat: false
    disableIPSecReplayProtection: false
    sku: {
      name: 'vpngw1'
      tier: 'vpngw1'
    }
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    enableBgp: false
    activeActive: false
    vpnGatewayGeneration: 'Generation1'
    allowRemoteVnetTraffic: false
    allowVirtualWanTraffic: false
  }
}

// create local network gateway for azure vpn connection
resource hubLng 'Microsoft.Network/localNetworkGateways@2023-06-01' = {
  name: hubLngName
  location: location
  properties: {
    localNetworkAddressSpace: {
      addressPrefixes: ['${hubVNet1Address}']
    }
    gatewayIpAddress: hubVPNGWpip.properties.ipAddress
  }
}

/*
------------------
output section
------------------
*/

// return the vpn gateway ID and LNG ID to use from parent template
output hubVPNGWId string = hubVPNGW.id
output hubLngId string = hubLng.id

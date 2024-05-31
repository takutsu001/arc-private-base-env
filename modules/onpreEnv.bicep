/*
------------------
param section
------------------
*/
// Common
param location string
param myipaddress string
// VNet1
param onpreVNet1Name string 
param onpreVNet1Address string
// VNet1 - VM Subnet
param onpreVNet1Subnet1Name string
param onpreVNet1Subnet1Address string
// VNet1 - VPN Gateway Subnet
param onpreVNet1Subnet2Name string
param onpreVNet1Subnet2Address string
// VNet2
param onpreVNet2Name string 
param onpreVNet2Address string
// VNet2 - DNS Subnet
param onpreVNet2Subnet1Name string
param onpreVNet2Subnet1Address string
// for VM
param onpreVNet1vm1Name string
param onpreVNet1vm1OSType string
param onpreVNet1vm1pip string
param onpreVNet1vm2Name string
param onpreVNet1vm2OSType string
param onpreVNet1vm2pip string
param onpreVNet2vm1Name string
param onpreVNet2vm1OSType string
param onpreVNet2vm1pip string
param vmSizeWindows string
param spotvm string
@secure()
param adminUserName string
@secure()
param adminPassword string
// for VPN Gateway
param onpreVPNGWName string
param onpreLngName string

/*
------------------
var section
------------------
*/
// VNet1 - VM Subnet
var onpreVNet1Subnet1 = { 
  name:  onpreVNet1Subnet1Name
  properties: { 
    addressPrefix: onpreVNet1Subnet1Address
    networkSecurityGroup: {
    id: nsgDefault1.id
    }
  }
}
// VNet1 - VPN Gateway Subnet
var onpreVNet1Subnet2 = { 
  name: onpreVNet1Subnet2Name 
  properties: { 
    addressPrefix: onpreVNet1Subnet2Address
  }
}
// VNet2 - DNS Subnet
var onpreVNet2Subnet1 = { 
  name: onpreVNet2Subnet1Name 
  properties: { 
    addressPrefix: onpreVNet2Subnet1Address
    networkSecurityGroup: {
    id: nsgDefault2.id
    }
  }
}
// for VMs (Name, PIP, OS Type, OS Image)
var vmNames = [
  onpreVNet1vm1Name
  onpreVNet1vm2Name
  onpreVNet2vm1Name
]
var pips = [
  onpreVNet1vm1pip
  onpreVNet1vm2pip
  onpreVNet2vm1pip
]
var osTypes = [
  onpreVNet1vm1OSType
  onpreVNet1vm2OSType
  onpreVNet2vm1OSType
]
var osImages = [for i in range(0, length(osTypes)): {
  publisher: 'MicrosoftWindowsServer'
  offer: 'WindowsServer'
  sku: (osTypes[i] == 'win2k12') ? '2012-r2-datacenter-smalldisk-g2' : (osTypes[i] == 'win2k16') ? '2016-datacenter-smalldisk-g2' : (osTypes[i] == 'win2k19') ? '2019-datacenter-smalldisk-g2' : '2022-datacenter-azure-edition-hotpatch-smalldisk'
  version: 'latest'
}]

/*
------------------
resource section
------------------
*/

// create network security group for VNet1 (onpre-VNet)
resource nsgDefault1 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: 'onpre-nsg'
  location: location
  properties: {
  //  securityRules: [
  //    {
  //     name: 'Allow-SSH'
  //      properties: {
  //      description: 'description'
  //      protocol: 'TCP'
  //      sourcePortRange: '*'
  //      destinationPortRange: '22'
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

// create network security group for VNet2 (onpre-DNSVNet)
resource nsgDefault2 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: 'onpredns-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-RDP'
        properties: {
        description: 'RDP access permission from your own PC.'
        protocol: 'TCP'
        sourcePortRange: '*'
        destinationPortRange: '3389'
        sourceAddressPrefix: myipaddress
        destinationAddressPrefix: '*'
        access: 'Allow'
        priority: 1000
        direction: 'Inbound'
        }
      }
    ]
  }
}

// create onpreVNet & onpreSubnet (VNet1)
resource onpreVNet 'Microsoft.Network/virtualNetworks@2021-05-01' = { 
  name: onpreVNet1Name 
  location: location 
  properties: { 
    addressSpace: { 
      addressPrefixes: [ 
        onpreVNet1Address 
      ] 
    } 
    subnets: [ 
      onpreVNet1Subnet1
      onpreVNet1Subnet2
    ]
  }
  // Get subnet information where VMs are connected.
  resource onpreVMSubnet 'subnets' existing = {
    name: onpreVNet1Subnet1Name
  }
  // Get subnet information where VPN Gateway is connected.
  resource onpreGatewaySubnet 'subnets' existing = {
    name: onpreVNet1Subnet2Name
  }
}

// create onprednsVNet & onprednsSubnet (VNet2)
resource onprednsVNet 'Microsoft.Network/virtualNetworks@2021-05-01' = { 
  name: onpreVNet2Name
  location: location 
  properties: { 
    addressSpace: { 
      addressPrefixes: [ 
        onpreVNet2Address
      ] 
    } 
    subnets: [ 
      onpreVNet2Subnet1
    ]
  }
  // Get subnet information where VMs are connected.
  resource onprednsSubnet 'subnets' existing = {
    name: onpreVNet2Subnet1Name
  }
}

// create VNet Peering from VNet1 to VNet2
resource vnet1ToVnet2Peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-11-01' = {
  parent: onpreVNet
  name: 'onpre-to-onpredns-peering'
  dependsOn: [
    onpreVPNGW
  ]
  properties: {
    remoteVirtualNetwork: {
      id: onprednsVNet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: false
  }
}

// create VNet Peering from VNet2 to VNet1
resource vnet2ToVnet1Peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-11-01' = {
  parent: onprednsVNet
  name: 'onpredns-to-onpre-peering'
  dependsOn: [
    onpreVPNGW
  ]
  properties: {
    remoteVirtualNetwork: {
      id: onpreVNet.id
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: true
  }
}

// create public ip address for Windows VM
resource publicIp 'Microsoft.Network/publicIPAddresses@2022-05-01' = [for i in range(0, length(pips)): if (pips[i] == 'yes') {
  name: '${vmNames[i]}-pip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}]

// create VM1,VM2 in onpreVNet (VNet1) and VM3 in onprednsVNet (VNet2)
// create network interface for Windows VM
resource networkInterfaces 'Microsoft.Network/networkInterfaces@2023-04-01' = [for i in range(0, length(vmNames)): {
  name: '${vmNames[i]}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: (vmNames[i] == onpreVNet2vm1Name) ? onprednsVNet::onprednsSubnet.id : onpreVNet::onpreVMSubnet.id
          }
          publicIPAddress: pips[i] == 'yes' ? {
            id: resourceId('Microsoft.Network/publicIPAddresses', '${vmNames[i]}-pip')
          } : null
        }
      }
    ]
  }
}]

// create VMs in onpreVNet (VNet1) and onprednsVNet (VNet2)
resource winVMs 'Microsoft.Compute/virtualMachines@2023-03-01' = [for i in range(0, length(vmNames)): {
  name: vmNames[i]
  location: location
  dependsOn: [
    networkInterfaces[i]
  ]
  properties: {
    hardwareProfile: {
      vmSize: vmSizeWindows
    }
    priority: spotvm == 'yes' ? 'Spot' : 'Regular'
    evictionPolicy: spotvm == 'yes' ? 'Deallocate' : null
    osProfile: {
      computerName: vmNames[i]
      adminUsername: adminUserName
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: osImages[i]
      osDisk: {
        name: '${vmNames[i]}-disk'
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
          id: resourceId('Microsoft.Network/networkInterfaces', '${vmNames[i]}-nic')
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
  }
}]

// create public ip address for VPN Gateway
resource onpreVPNGWpip 'Microsoft.Network/publicIPAddresses@2022-05-01' = {
  name: '${onpreVPNGWName}-pip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

// create VPN Gateway for Onpre (RouteBased)
resource onpreVPNGW 'Microsoft.Network/virtualNetworkGateways@2023-06-01' = {
  name: onpreVPNGWName
  location: location
  properties: {
    enablePrivateIpAddress: false
    ipConfigurations: [
      {
        name: '${onpreVPNGWName}-ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: onpreVPNGWpip.id
          }
          subnet: {
            id: onpreVNet::onpreGatewaySubnet.id
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
resource onpreLng 'Microsoft.Network/localNetworkGateways@2023-06-01' = {
  name: onpreLngName
  location: location
  properties: {
    localNetworkAddressSpace: {
      addressPrefixes: ['${onpreVNet1Address}']
    }
    gatewayIpAddress: onpreVPNGWpip.properties.ipAddress
  }
}


/*
------------------
output section
------------------
*/
// return the private ip address of the vm to use from parent template
@description('Return the private IP addresses of all VMs.')
output vmPrivateIps array = [for i in range(0, length(vmNames)): networkInterfaces[i].properties.ipConfigurations[0].properties.privateIPAddress]

// return the vpn gateway ID and LNG ID to use from parent template
output onpreVPNGWId string = onpreVPNGW.id
output onpreLngId string = onpreLng.id

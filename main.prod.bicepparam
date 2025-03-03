using 'main.bicep'

param resourceGroupName = 'arc-private-RG'
param resourceGroupLocation = 'japaneast'
// ---- for Firewall Rule ----
// your ip address for RDP (ex. xxx.xxx.xxx.xxx)
param myipaddress = '<Public IP your PC Address>'
// ---- param for Hub ----
param hubVNetName = 'Hub-VNet'
param hubVNetAddress = '10.0.0.0/16'
param hubSubnetName1 = 'Hub-PESubnet'
param hubSubnetAddress1 = '10.0.10.0/24'
param hubSubnetName2 = 'Hub-DNSSubnet'
param hubSubnetAddress2 = '10.0.20.0/24'
param hubSubnetName3 = 'GatewaySubnet'
param hubSubnetAddress3 = '10.0.200.0/27'
// for VPN Gateway
param hubVPNGWName = 'azure-vpngw'
param hubLngName = 'Azure-LNG'
// for Azure Arc Private Link Scope
param privateLinkScopeName = 'AAPLS'
// ---- param for Onpre ----
// VNet #1
param onpreVNetName = 'Onpre-VNet' 
param onpreVNetAddress = '172.16.0.0/16'
param onpreSubnetName1 = 'Onpre-VMSubnet'
param onpreSubnetAddress1 = '172.16.0.0/24'
param onpreSubnetName2 = 'GatewaySubnet'
param onpreSubnetAddress2 = '172.16.200.0/27'
// VNet #2
param onpreVNet2Name = 'Onpre-DNSVNet' 
param onpreVNet2Address = '172.20.0.0/16'
param onpreSubnet2Name1 = 'Onpre-DNSSubnet'
param onpreSubnet2Address1 = '172.20.0.0/24'
param onprevmName2 = 'onpre-dns'
param onprevm2ip = '172.20.0.4'
// for VPN Gateway
param onpreVPNGWName = 'onpre-vpngw'
param onpreLngName = 'Onpre-LNG'
// ---- Common param for VM ----
param vmSizeWindows = 'Standard_B2ms'
param adminUserName = 'cloudadmin'
param adminPassword = 'msjapan1!msjapan1!'
// ---- Common param for VPNGW ----
param connectionsharedkey = 'msjapan1!msjapan1!'



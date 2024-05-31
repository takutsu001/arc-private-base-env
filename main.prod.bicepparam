using 'main.bicep'

param resourceGroupName = 'arc-private-rg'
param resourceGroupLocation = 'japaneast'
// ---- for Firewall Rule ----
// your ip address for SSH (ex. xxx.xxx.xxx.xxx)
param myipaddress = '124.37.254.233'
// ---- param for Hub ----
param hubVNet1Name = 'Hub-VNet'
param hubVNet1Address = '10.0.0.0/16'
param hubVNet1Subnet1Name = 'Hub-VMSubnet'
param hubVNet1Subnet1Address = '10.0.0.0/24'
param hubVNet1Subnet2Name = 'Hub-PESubnet'
param hubVNet1Subnet2Address = '10.0.10.0/26'
param hubVNet1Subnet3Name = 'Hub-DNSSubnet'
param hubVNet1Subnet3Address = '10.0.20.0/26'
param hubVNet1Subnet4Name = 'GatewaySubnet'
param hubVNet1Subnet4Address = '10.0.200.0/27'
// for VPN Gateway
param hubVPNGWName = 'azure-vpngw'
param hubLngName = 'Azure-LNG'
// ---- param for Onpre ----
// VNet1
param onpreVNet1Name = 'Onpre-VNet' 
param onpreVNet1Address = '172.16.0.0/16'
param onpreVNet1Subnet1Name = 'Onpre-VMSubnet'
param onpreVNet1Subnet1Address = '172.16.0.0/24'
param onpreVNet1Subnet2Name = 'GatewaySubnet'
param onpreVNet1Subnet2Address = '172.16.200.0/27'
// VNet2
param onpreVNet2Name = 'Onpre-DNSVNet'
param onpreVNet2Address = '172.17.0.0/16'
param onpreVNet2Subnet1Name = 'Onpre-DNSSubnet'
param onpreVNet2Subnet1Address = '172.17.0.0/24'
// for VM in VNet1
// OStype choose from win2k12, win2k19, win2k22
// pip choose from yes, no
param onpreVNet1vm1Name = 'onpre-win2k12'
param onpreVNet1vm1OSType = 'win2k12'
param onpreVNet1vm1pip = 'no'
param onpreVNet1vm2Name = 'onpre-win2k19'
param onpreVNet1vm2OSType = 'win2k19'
param onpreVNet1vm2pip = 'no'
// for VM in VNet2
// OStype choose from win2k12, win2k19, win2k22
// pip choose from yes, no
param onpreVNet2vm1Name = 'onpre-dns'
param onpreVNet2vm1OSType = 'win2k22'
param onpreVNet2vm1pip = 'yes'
// for VPN Gateway
// OStype choose from win2k12, win2k19, win2k22
// pip choose from yes, no
param onpreVPNGWName = 'onpre-vpngw'
param onpreLngName = 'Onpre-LNG'
// ---- Common param for VM ----
// spotvm choose from 'yes' or 'no'
param vmSizeWindows = 'Standard_D2ads_v5'
param adminUserName = 'cloudadmin'
param adminPassword = 'msjapan1!msjapan1!'
param spotvm = 'yes' 
// ---- Common param for VPNGW ----
param connectionsharedkey = 'msjapan1!msjapan1!'

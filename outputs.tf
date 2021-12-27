output "appgw_pubip" {
  value = azurerm_public_ip.appgw_pubip.ip_address
}

output "jumpbox_pubip" {
  value = azurerm_public_ip.jumpbox_pubip.ip_address
}


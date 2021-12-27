# build nic,nsg association
resource "azurerm_network_interface_security_group_association" "jumpbox_ass" {
  network_interface_id      = azurerm_network_interface.jumpbox_nic.id
  network_security_group_id = azurerm_network_security_group.jumpbox_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "web_ass" {
  subnet_id                 = azurerm_subnet.web_subnet.id
  network_security_group_id = azurerm_network_security_group.web_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "was_ass" {
  subnet_id                 = azurerm_subnet.was_subnet.id
  network_security_group_id = azurerm_network_security_group.was_nsg.id
}

resource "azurerm_subnet_nat_gateway_association" "natgw_ass" {
  subnet_id      = azurerm_subnet.was_subnet.id
  nat_gateway_id = azurerm_nat_gateway.natgw.id
}

resource "azurerm_nat_gateway_public_ip_association" "natgw_pubip_ass" {
  nat_gateway_id       = azurerm_nat_gateway.natgw.id
  public_ip_address_id = azurerm_public_ip.natgw_pubip.id
}

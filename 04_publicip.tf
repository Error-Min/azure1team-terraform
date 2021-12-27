# build pubilc ip (can set domain name label)
resource "azurerm_public_ip" "appgw_pubip" {
  name                = "${var.resource_names}-appgw-pubip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "jumpbox_pubip" {
  name                = "${var.resource_names}-jumpbox-pubip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "natgw_pubip" {
  name                = "i${var.resource_names}-natgw_pubip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = [1]
}

/* data "azurerm_public_ip" "ityun_jumpbox_pubip" {
  name                = "${var.resource_names}-jumpbox-pubip"
  resource_group_name = azurerm_resource_group.rg.name
}
 */
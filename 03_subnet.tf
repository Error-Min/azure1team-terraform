# build subnets
resource "azurerm_subnet" "appgw_subnet" {
  name                 = "${var.resource_names}-appgw-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/28"]
}

resource "azurerm_subnet" "web_subnet" {
  name                 = "${var.resource_names}-web-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.10.0/28"]
}

resource "azurerm_subnet" "lb_subnet" {
  name                 = "${var.resource_names}-lb-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/29"]
}

resource "azurerm_subnet" "was_subnet" {
  name                 = "${var.resource_names}-was-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.20.0/28"]
}

resource "azurerm_subnet" "db_subnet" {
  name                                           = "${var.resource_names}-db-subnet"
  resource_group_name                            = azurerm_resource_group.rg.name
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  address_prefixes                               = ["10.0.3.0/29"]
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_subnet" "jumpbox_subnet" {
  name                 = "${var.resource_names}-jumpbox-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.4.0/29"]
}

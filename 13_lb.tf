resource "azurerm_lb" "smlee_lb" {
  name                = "${var.resource_names}-lb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "wasPrivateIP"
    subnet_id                     = azurerm_subnet.lb_subnet.id
    private_ip_address            = "10.0.2.5"
    private_ip_address_allocation = "Static"
    private_ip_address_version    = "IPv4"
    availability_zone             = "Zone-Redundant"
  }
}

resource "azurerm_lb_backend_address_pool" "lb_bp" {
  name                = "${var.resource_names}-lb-bp"
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.smlee_lb.id
}

resource "azurerm_lb_probe" "lb_probe" {
  name                = "${var.resource_names}-lb-probe"
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.smlee_lb.id
  port                = 8009
}

resource "azurerm_lb_rule" "ityun_lb_rule" {
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.smlee_lb.id
  name                           = "AJP"
  protocol                       = "Tcp"
  frontend_port                  = 8009
  backend_port                   = 8009
  disable_outbound_snat          = true
  backend_address_pool_ids        = [azurerm_lb_backend_address_pool.lb_bp.id]
  frontend_ip_configuration_name = "wasPrivateIP"
  probe_id                       = azurerm_lb_probe.lb_probe.id
}

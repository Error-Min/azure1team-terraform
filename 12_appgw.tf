resource "azurerm_application_gateway" "web_appgw" {
  name                = "${var.resource_names}-web-appgw"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  zones               = [1, 2, 3]

  sku {
    name = "Standard_v2"
    tier = "Standard_v2"
  }

  autoscale_configuration {
    min_capacity = 2
    max_capacity = 10
  }

  gateway_ip_configuration {
    name      = "appgw-conf"
    subnet_id = azurerm_subnet.appgw_subnet.id
  }

  frontend_port {
    name = "frontend-80"
    port = 80
  }

  frontend_port {
    name = "frontend-443"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "public-ip"
    public_ip_address_id = azurerm_public_ip.appgw_pubip.id
  }

  frontend_ip_configuration {
    name                          = "private"
    subnet_id                     = azurerm_subnet.appgw_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.5"
  }

  backend_address_pool {
    name = "backend"
  }

  backend_http_settings {
    name                                = "settings-80"
    pick_host_name_from_backend_address = true
    #probe_name                          = "probe-443"
    cookie_based_affinity = "Disabled"
    port                  = 80
    path                  = "/"
    protocol              = "Http"
    request_timeout       = 20
  }


  backend_http_settings {
    name                                = "settings-443"
    pick_host_name_from_backend_address = true
    probe_name                          = "probe-443"
    cookie_based_affinity               = "Disabled"
    port                                = 443
    path                                = "/"
    protocol                            = "Https"
    request_timeout                     = 20
  }

  http_listener {
    name                           = "listener-80"
    frontend_ip_configuration_name = "public-ip"
    frontend_port_name             = "frontend-80"
    protocol                       = "Http"
  }

  http_listener {
    name                           = "listener-443"
    frontend_ip_configuration_name = "public-ip"
    frontend_port_name             = "frontend-443"
    protocol                       = "Https"
    ssl_certificate_name           = "cert"
  }

  ssl_certificate {
    name     = "cert"
    data     = filebase64("certificate.pfx")
    password = "1234"
  }

  probe {
    name                                      = "probe-443"
    path                                      = "/"
    protocol                                  = "Https"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    pick_host_name_from_backend_http_settings = true
    //host = "contoso.com"

    match {}
  }

  redirect_configuration {
    name                 = "redirect"
    redirect_type        = "Permanent"
    include_path         = true
    include_query_string = true
    target_listener_name = "listener-443"
  }

  request_routing_rule {
    name                       = "rule-443"
    rule_type                  = "Basic"
    http_listener_name         = "listener-443"
    backend_address_pool_name  = "backend"
    backend_http_settings_name = "settings-80"
  }

  request_routing_rule {
    name                        = "rule-80"
    rule_type                   = "Basic"
    http_listener_name          = "listener-80"
    redirect_configuration_name = "redirect"
  }
}

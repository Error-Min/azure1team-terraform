resource "azurerm_mysql_server" "mysql" {
  name                         = "${var.resource_names}-mysql"
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  administrator_login          = var.admin_user
  administrator_login_password = var.admin_password
  #create_mode                  = "Replica"

  sku_name   = "GP_Gen5_8"
  storage_mb = 5120
  version    = "5.7"

  auto_grow_enabled     = true
  backup_retention_days = 7
  #geo_redundant_backup_enabled      = true
  #infrastructure_encryption_enabled = true
  public_network_access_enabled = false
  ssl_enforcement_enabled       = false
  #ssl_minimal_tls_version_enforced  = "TLS1_2"
}

resource "azurerm_mysql_server" "mysql_replica" {
  name                          = "${var.resource_names}-mysql-replica"
  auto_grow_enabled             = true
  backup_retention_days         = 7
  create_mode                   = "Replica"
  geo_redundant_backup_enabled  = false
  location                      = "koreasouth"
  public_network_access_enabled = false
  resource_group_name           = azurerm_resource_group.rg.name
  sku_name                      = "GP_Gen5_8"
  ssl_enforcement_enabled       = false
  #ssl_minimal_tls_version_enforced = "TLSEnforcementDisabled"
  storage_mb                = 5120
  version                   = "5.7"
  creation_source_server_id = azurerm_mysql_server.mysql.id
}

resource "azurerm_mysql_database" "petclinic" {
  name                = "petclinic"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_server.mysql.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

/* resource "azurerm_mysql_firewall_rule" "mysqlfw" {
  name                = "${var.resource_names}-mysqlfw"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_server.ityun_replica.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
} */

# cofigure mysql
resource "azurerm_mysql_configuration" "wait_timeout" {
  name                = "wait_timeout"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_server.mysql.name
  value               = "2147483"
}

resource "azurerm_mysql_configuration" "time_zone" {
  name                = "time_zone"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_mysql_server.mysql.name
  value               = "+09:00"
}

# mysql private endpoint
resource "azurerm_private_dns_zone" "private_dns_zone" {
  name                = "privatelink.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dnslink" {
  name                  = "${var.resource_names}-dnslink"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_endpoint" "private_endpoint" {
  name                = "${var.resource_names}-private-endpoint"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.db_subnet.id

  private_dns_zone_group {
    name                 = "privatednszonegroup"
    private_dns_zone_ids = [azurerm_private_dns_zone.private_dns_zone.id]
  }

  private_service_connection {
    name                           = "privateendpointconnection"
    private_connection_resource_id = azurerm_mysql_server.mysql.id
    is_manual_connection           = false
    subresource_names              = ["mysqlServer"]
  }
}

# mysql-replica private endpoint
resource "azurerm_private_endpoint" "replica_private_endpoint" {
  name                = "${var.resource_names}_replica_private_endpoint"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.db_subnet.id

  private_dns_zone_group {
    name                 = "privatednszonegroup"
    private_dns_zone_ids = [azurerm_private_dns_zone.private_dns_zone.id]
  }

  private_service_connection {
    name                           = "privateendpointconnection"
    private_connection_resource_id = azurerm_mysql_server.mysql_replica.id
    is_manual_connection           = false
    subresource_names              = ["mysqlServer"]
  }
}

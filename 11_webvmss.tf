resource "azurerm_linux_virtual_machine_scale_set" "web_vmss" {
  name                            = "${var.resource_names}-web-vmss"
  location                        = azurerm_resource_group.rg.location # (2)
  resource_group_name             = azurerm_resource_group.rg.name
  sku                             = "Standard_DS1_v2" # 머신 디스크 크기 선택 및 vmss 개수 지정 
  instances                       = 1                 # vmss 가상머신 개수.
  admin_username                  = var.admin_user
  admin_password                  = var.admin_password
  disable_password_authentication = false
  upgrade_mode                    = "Automatic"
  zones                           = [1, 2, 3]
  zone_balance                    = true
  custom_data                     = base64encode("web.sh")
  #health_probe_id                 = azurerm_application_gateway.ityun_web_appgw.probe.id

  /* admin_ssh_key {
    username   = "nana"
    public_key = file("../.ssh/id_rsa.pub")
  } */

  source_image_reference {
    # VM OS 설정및 변경
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.5"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  data_disk {
    lun     = 0
    caching = "ReadWrite"
    #create_option = "Empty"
    disk_size_gb         = 10
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      name                                         = "IPConfiguration"
      subnet_id                                    = azurerm_subnet.web_subnet.id
      primary                                      = true
      application_gateway_backend_address_pool_ids = [azurerm_application_gateway.web_appgw.backend_address_pool[0].id]
    }
  }

  extension {
    name                       = "CustomScript"
    publisher                  = "Microsoft.Azure.Extensions"
    type                       = "CustomScript"
    type_handler_version       = "2.1"
    auto_upgrade_minor_version = true

    settings = <<SETTINGS
  {
      "script": "${filebase64("web.sh")}"
  }
  SETTINGS
  }
}

resource "azurerm_monitor_autoscale_setting" "web_auto" {
  name                = "${var.resource_names}-web-auto"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.web_vmss.id

  profile {
    name = "ityun-web-AutoScale"

    capacity {
      default = 1
      minimum = 1
      maximum = 9
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.web_vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 70
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "2"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.web_vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 30
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }
}

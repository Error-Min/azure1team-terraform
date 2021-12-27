resource "azurerm_linux_virtual_machine_scale_set" "was_vmss" {
  depends_on                      = [azurerm_lb.smlee_lb]
  name                            = "${var.resource_names}-was-vmss"
  location                        = azurerm_resource_group.rg.location # (2)
  resource_group_name             = azurerm_resource_group.rg.name
  sku                             = "Standard_DS1_v2"
  instances                       = 1 # vmss 가상머신 개수.
  admin_username                  = var.admin_user
  admin_password                  = var.admin_password
  disable_password_authentication = false
  upgrade_mode                    = "Automatic"
  zones                           = [1, 2, 3]
  zone_balance                    = true
  custom_data                     = base64encode("was.sh")
  #health_probe_id                 = azurerm_lb_probe.ityun_lb_probe.id
  #overprovision                   = false
  # log_analytics_agent_enabled

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
    #create_option        = "Empty"
    disk_size_gb         = 10
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      name                                   = "IPConfiguration"
      subnet_id                              = azurerm_subnet.was_subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.lb_bp.id]
      primary                                = true
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
      "script": "${filebase64("was.sh")}"
  }
  SETTINGS
  }

  # Since these can change via auto-scaling outside of Terraform,
  # let's ignore any changes to the number of instances
  lifecycle {
    ignore_changes = [instances]
  }
}


resource "azurerm_monitor_autoscale_setting" "was_auto_scale" {
  name                = "${var.resource_names}-was-auto-scale"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.was_vmss.id

  profile {
    name = "AutoScale"

    capacity {
      default = 1
      minimum = 1
      maximum = 9
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.was_vmss.id
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
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.was_vmss.id
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

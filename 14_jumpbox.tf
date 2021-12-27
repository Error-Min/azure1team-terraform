resource "azurerm_linux_virtual_machine" "jumpbox" {

  name                            = "${var.resource_names}-jumpbox"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = "Standard_B2s"
  admin_username                  = var.admin_user
  admin_password                  = var.admin_password
  network_interface_ids           = [azurerm_network_interface.jumpbox_nic.id]
  disable_password_authentication = false

  /* admin_ssh_key {
    username   = "nana"
    public_key = file("../.ssh/id_rsa.pub")
  } */

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.5"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "jumpbox_ex" {
  name                 = "${var.resource_names}-jumpbox-ex"
  virtual_machine_id   = azurerm_linux_virtual_machine.jumpbox.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = <<SETTINGS
    {   
    "script": "${filebase64("jumpbox.sh")}"
    }
SETTINGS
}

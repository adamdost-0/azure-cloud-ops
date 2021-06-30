resource "azurerm_network_interface" "USDOD-NIC" {
    count                       = length(var.VMs)
    name                        = "AZ-DOD-NIC-${var.VMs[count.index]}"
    location                    = var.location
    resource_group_name         = var.resource_group_name

    ip_configuration {
        name                          = "ipcofnig"
        subnet_id                     = var.subnetId
        private_ip_address_allocation = "Dynamic"
    }
}


resource "azurerm_linux_virtual_machine" "MOD-VM-1" {
  count               = length(var.VMs)
  name                = "AZ-DOD-${var.VMs[count.index]}"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  size                = "Standard_F2"
  admin_username      = "adamdost"
  network_interface_ids =  [
    element(azurerm_network_interface.USDOD-NIC.*.id, count.index)
  ]


  admin_ssh_key {
    username   = "adamdost"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name = "DSK-${var.VMs[count.index]}"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

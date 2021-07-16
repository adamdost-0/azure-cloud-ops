output "vm-ids" {
    description = "Output Value of the Moduel VM Deployment"
    value   = azurerm_linux_virtual_machine.MOD-VM-1
    sensitive = true
}


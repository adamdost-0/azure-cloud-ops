resource "azurerm_recovery_services_vault" "US-GOV-VAULT" {
  name                = var.vault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  soft_delete_enabled = false # SET TO ENABLE / ONLY DISABLE WHEN TESTING/DEBUGGING TERRAFORM
}

#### BACK UP POLICY
resource "azurerm_backup_policy_vm" "VM-POLICY-01" {
  name                = "VM-POLICY-01"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.US-GOV-VAULT.name

  backup {
    frequency = "Daily"
    time      = "23:00"
  }
   retention_daily {
    count = 10
  }

}

resource "azurerm_site_recovery_fabric" "primary" {
  name                = "primary-fabric"
  resource_group_name = var.secondary_resource_group_name
  recovery_vault_name = var.vault_name
  location            = var.primary_location
}

resource "azurerm_site_recovery_fabric" "secondary" {
  name                = "secondary-fabric"
  resource_group_name = var.secondary_resource_group_name
  recovery_vault_name = var.vault_name
  location            = var.secondary_location
}
resource "azurerm_site_recovery_protection_container" "primary" {
  name                 = "primary-protection-container"
  resource_group_name = var.secondary_resource_group_name
  recovery_vault_name = var.vault_name
  recovery_fabric_name = azurerm_site_recovery_fabric.primary.name
}
resource "azurerm_site_recovery_protection_container" "secondary" {
  name                 = "secondary-protection-container"
  resource_group_name = var.secondary_resource_group_name
  recovery_vault_name = var.vault_name
  recovery_fabric_name = azurerm_site_recovery_fabric.secondary.name
}
resource "azurerm_site_recovery_replication_policy" "policy" {
  name                                                 = "Default-VM-Policy"
  resource_group_name                                  = var.secondary_resource_group_name
  recovery_vault_name                                  = var.vault_name
  recovery_point_retention_in_minutes                  = 24 * 60
  application_consistent_snapshot_frequency_in_minutes = 4 * 60
}
resource "azurerm_site_recovery_protection_container_mapping" "container-mapping" {
  name                                      = "container-mapping"
  resource_group_name                       = var.secondary_resource_group_name
  recovery_vault_name                       = var.vault_name
  recovery_fabric_name                      = azurerm_site_recovery_fabric.primary.name
  recovery_source_protection_container_name = azurerm_site_recovery_protection_container.primary.name
  recovery_target_protection_container_id   = azurerm_site_recovery_protection_container.secondary.id
  recovery_replication_policy_id            = azurerm_site_recovery_replication_policy.policy.id
}

resource "azurerm_storage_account" "primary" {
  name                     = "azstgprimarycache"
  location                 = var.primary_location
  resource_group_name      = var.primary_resource_group_name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

/*
resource "azurerm_site_recovery_replicated_vm" "vm-replication" {
  count                                     = length(var.vm_id)
  name                                      = "REPLICATED-VM"
  resource_group_name                       = var.secondary_resource_group_name
  recovery_vault_name                       = var.vault
  source_recovery_fabric_name               = azurerm_site_recovery_fabric.primary.name
  source_vm_id                              = azurerm_virtual_machine.vm_id.*.id[count.index]
  recovery_replication_policy_id            = azurerm_site_recovery_replication_policy.policy.id
  source_recovery_protection_container_name = azurerm_site_recovery_protection_container.primary.name

  target_resource_group_id                = var.secondary_rgp_id
  target_recovery_fabric_id               = azurerm_site_recovery_fabric.secondary.id
  target_recovery_protection_container_id = azurerm_site_recovery_protection_container.secondary.id

  managed_disk {
    disk_id                    = azurerm_virtual_machine.vm_id[count.index].*.storage_os_disk[0].managed_disk_id
    staging_storage_account_id = azurerm_storage_account.primary.id
    target_resource_group_id   = azurerm_resource_group.secondary.id
    target_disk_type           = "Premium_LRS"
    target_replica_disk_type   = "Premium_LRS"
  }

  network_interface {
    source_network_interface_id   = azurerm_network_interface.nic_ids.*.id[count.index]
    target_subnet_name            = "network2-subnet"
  }
}
*/
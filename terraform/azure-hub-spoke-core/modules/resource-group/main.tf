resource "azurerm_resource_group" "RGP-LOOP" {
  count    = length(var.resource_group_name)
  name     = "${var.resource_group_name[count.index]}"
  location = var.azureRegion
}
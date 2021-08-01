variable "base_url" {
  type    = string
  default = "https://www.powershellgallery.com/api/v2/package/"
}

resource "azurerm_automation_module" "module_loop" {
  count                   = length(var.module_list)
  name                    = var.module_list[count.index]
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name

  module_link {
    uri = format("%s%s", var.base_url, var.module_list[count.index])
  }
}

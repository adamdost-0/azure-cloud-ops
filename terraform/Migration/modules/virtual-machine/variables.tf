variable VMs {
  type = list
  description = "List of VM NAME's for creation"
}

variable resource_group_name {
  description = "Resource Group name"
  type        = string
}

variable location {
  description = "Location in which to deploy the network"
  type        = string
}

variable subnetId {
    description = "SubnetID inheritance"
    type = string
}


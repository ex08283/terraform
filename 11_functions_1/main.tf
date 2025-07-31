locals {
  formatted_name = replace(lower(var.project_name)," ","-")
  formatted_ports = split(",",var.allowed_ports)
  nsg_rules = [for port in local.formatted_ports : {
    name = "port-${port}"
    port = port
    description = "allowed traffic on port:${port}"
  }]


  vm_size = lookup(var.vm_sizes,var.environment,"standard_D4s_v3")


}

resource "azurerm_resource_group" "example" {

# With create_before_destroy = true in the lifecycle block of the resource group, if you make a change that requires replacing the resource group (like changing its name or location),
# Terraform will first create the new resource group, move dependent resources (like storage accounts) to it, and only then destroy the old group. This prevents downtime and accidental deletion of dependent resources.


  name     = "${local.formatted_name}-resources"
  location = var.allowed_locations[0] # Use the first allowed location from the list

tags = var.resource_tags

}

resource "azurerm_network_security_group" "nsg" {
  name = "${local.formatted_name}-nsg"
  location = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  
  #The dynamic block lets you programmatically generate nested blocks in Terraform resources
  dynamic "security_rule" {
    for_each = local.nsg_rules
    content {
      name = security_rule.key
      priority = 100
      direction = "Inbound"
      access = "Allow"
      protocol = "Tcp"
      source_port_range = "*"
      destination_port_range = security_rule.value.port
      source_address_prefix = "*"
      destination_address_prefix = "*"
      description = security_rule.value.description
      
    }
  }
  
}


  


output "rgname" {
  value = azurerm_resource_group.example.name
}

output "nsg_rules" {
  value = local.nsg_rules
  
}

output "vm_size" {  
  value = local.vm_size
  
}


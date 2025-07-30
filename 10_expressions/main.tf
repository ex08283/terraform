resource "azurerm_resource_group" "example" {

# With create_before_destroy = true in the lifecycle block of the resource group, if you make a change that requires replacing the resource group (like changing its name or location),
# Terraform will first create the new resource group, move dependent resources (like storage accounts) to it, and only then destroy the old group. This prevents downtime and accidental deletion of dependent resources.


  name     = "${var.environment}-resources"
  location = var.allowed_locations[0] # Use the first allowed location from the list
  tags = {
    businesscriticality = var.resource_tags.businesscriticality
    businessunit        = var.resource_tags.businessunit
    costcentre         = var.resource_tags.costcentre
    dataclassification = var.resource_tags.dataclassification
    workloadname       = var.resource_tags.workloadname
  }
}

resource "azurerm_network_security_group" "nsg" {
  name = var.environment == "dev" ? "nsg_true" : "nsg_false"
  location = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  
  #The dynamic block lets you programmatically generate nested blocks in Terraform resources
  dynamic "security_rule" {
    for_each = local.nsg_rules
    content {
      name = security_rule.key
      priority = security_rule.value.priority
      direction = "Inbound"
      access = "Allow"
      protocol = "Tcp"
      source_port_range = "*"
      destination_port_range = security_rule.value.destination_port_range
      source_address_prefix = "*"
      destination_address_prefix = "*"
      description = security_rule.value.description
      
    }
  }
  
}
  
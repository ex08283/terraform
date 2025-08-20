variable "day" {
    type = string
    default = "day24"
  
}

resource "azurerm_resource_group" "rg" {
    name = "${var.day}-rg"
    location = "UK South"
    tags = var.resource_tags
}

resource "azurerm_virtual_network" "vnet" {
  name = "${var.day}-vnet"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space = [ "10.0.0.0/16" ]
}

resource "azurerm_subnet" "sn" {
    name = "default"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes = [ "10.0.1.0/24" ]
  
}

resource "azurerm_service_plan" "sp" {
    name = "${var.day}-sp"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    os_type = "Linux"
    sku_name = "S1"
  
}

resource "azurerm_linux_web_app" "linapp" {
    name = "${var.day}-webapp-187089"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    service_plan_id = azurerm_service_plan.sp.id

    site_config {
      application_stack {
        node_version = "20-lts"
      }
    }
}

#tf state list
#show all resources in state file

# import existing resource using 
#tf import azurerm_resource_group.rg /subscriptions/8f2f2e98-2bdf-4cb7-a893-8a0e07a806d7/resourceGroups/day24-rg 

# how to remove resource from state
#tf state rm azurerm_resource_group.rg
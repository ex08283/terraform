resource "azurerm_resource_group" "rg" {
  location = "uksouth"
  name     = "test-group"
}



variable "day" {
    type = string
    default = "day245"
    description = "Name of the resource group"
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

resource "azurerm_linux_web_app_slot" "devslot" {
  app_service_id = azurerm_linux_web_app.linapp.id
  name           = "dev"
  site_config {
    always_on                         = false
    ftps_state                        = "FtpsOnly"
    ip_restriction_default_action     = "Allow"
    scm_ip_restriction_default_action = "Allow"
  }
}

#tf state list
#show all resources in state file

# import existing resource using 
#tf import azurerm_resource_group.rg /subscriptions/8f2f2e98-2bdf-4cb7-a893-8a0e07a806d7/resourceGroups/day24-rg 

# how to remove resource from state
#tf state rm azurerm_resource_group.rg
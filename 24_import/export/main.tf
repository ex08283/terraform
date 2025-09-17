resource "azurerm_resource_group" "res-0" {
  location = "uksouth"
  name     = "day24-rg"
  tags = {
    businesscriticality = "Low"
    businessunit        = "IT"
    costcentre          = "tf"
    dataclassification  = "Internal"
    workloadname        = "tf"
  }
}
resource "azurerm_virtual_network" "res-1" {
  address_space       = ["10.0.0.0/16"]
  location            = "uksouth"
  name                = "day24-vnet"
  resource_group_name = "day24-rg"
  tags = {
    businesscriticality = "Low"
    businessunit        = "IT"
    costcentre          = "tf"
    dataclassification  = "Internal"
    workloadname        = "tf"
  }
  depends_on = [
    azurerm_resource_group.res-0
  ]
}
resource "azurerm_subnet" "res-2" {
  address_prefixes                  = ["10.0.1.0/24"]
  name                              = "default"
  private_endpoint_network_policies = "Enabled"
  resource_group_name               = "day24-rg"
  virtual_network_name              = "day24-vnet"
  depends_on = [
    azurerm_virtual_network.res-1
  ]
}
resource "azurerm_service_plan" "res-3" {
  location            = "uksouth"
  name                = "day24-sp"
  os_type             = "Linux"
  resource_group_name = "day24-rg"
  sku_name            = "S1"
  tags = {
    businesscriticality = "Low"
    businessunit        = "IT"
    costcentre          = "tf"
    dataclassification  = "Internal"
    workloadname        = "tf"
  }
  depends_on = [
    azurerm_resource_group.res-0
  ]
}
resource "azurerm_linux_web_app" "res-4" {
  location            = "uksouth"
  name                = "day24-webapp-187089"
  resource_group_name = "day24-rg"
  service_plan_id     = azurerm_service_plan.res-3.id
  tags = {
    businesscriticality = "Low"
    businessunit        = "IT"
    costcentre          = "tf"
    dataclassification  = "Internal"
    workloadname        = "tf"
  }
  site_config {
  }
}
# resource "azurerm_app_service_custom_hostname_binding" "res-8" {
#   app_service_name    = "day24-webapp-187089"
#   hostname            = "day24-webapp-187089.azurewebsites.net"
#   resource_group_name = "day24-rg"
#   depends_on = [
#     azurerm_linux_web_app.res-4
#   ]
# }

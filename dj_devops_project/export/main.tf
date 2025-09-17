resource "azurerm_resource_group" "res-0" {
  location = "uksouth"
  name     = "test-group"
}
resource "azurerm_service_plan" "res-1" {
  location            = "uksouth"
  name                = "day245-sp"
  os_type             = "Linux"
  resource_group_name = "test-group"
  sku_name            = "S1"
  depends_on = [
    azurerm_resource_group.res-0
  ]
}
resource "azurerm_linux_web_app" "res-2" {
  location            = "uksouth"
  name                = "day245-webapp-187089"
  resource_group_name = "test-group"
  service_plan_id     = azurerm_service_plan.res-1.id
  site_config {
  }
}
resource "azurerm_app_service_custom_hostname_binding" "res-6" {
  app_service_name    = "day245-webapp-187089"
  hostname            = "day245-webapp-187089.azurewebsites.net"
  resource_group_name = "test-group"
  depends_on = [
    azurerm_linux_web_app.res-2
  ]
}
resource "azurerm_linux_web_app_slot" "res-7" {
  app_service_id = azurerm_linux_web_app.res-2.id
  name           = "dev"
  site_config {
    always_on                         = false
    ftps_state                        = "FtpsOnly"
    ip_restriction_default_action     = ""
    scm_ip_restriction_default_action = ""
  }
}
resource "azurerm_app_service_slot_custom_hostname_binding" "res-11" {
  app_service_slot_id = azurerm_linux_web_app_slot.res-7.id
  hostname            = "day245-webapp-187089-dev.azurewebsites.net"
}

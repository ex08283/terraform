resource "azurerm_resource_group" "rg1" {
  name     = var.rgname
  location = var.location
}
module "ServicePrincipal" {
  source                 = "../modules/ServicePrincipal"
  service_principal_name = var.service_principal_name

  depends_on = [
    azurerm_resource_group.rg1
  ]
  
}

resource "azurerm_role_assignment" "rolespn" {
  scope                = "/subscriptions/${var.SUB_ID}"
  role_definition_name = "Contributor"
  principal_id         = module.ServicePrincipal.service_principal_object_id

  depends_on = [
    module.ServicePrincipal
  ]
}

module "KeyVault" {
  source         = "../modules/keyvault"
  keyvault_name  = var.keyvault_name
  resource_group_name = azurerm_resource_group.rg1.name
  location       = azurerm_resource_group.rg1.location
  service_principal_name = var.service_principal_name
  service_principal_object_id      = module.ServicePrincipal.service_principal_object_id
  service_principal_tenant_id      = module.ServicePrincipal.service_principal_tenant_id
  depends_on = [
    module.ServicePrincipal
  ]
}

resource "azurerm_key_vault_secret" "example" {
  name = module.ServicePrincipal.client_id
  value = module.ServicePrincipal.client_secret
  key_vault_id = module.keyvault.keyvault_id
  depends_on = [
    module.KeyVault
  ]
}

module "aks" {
  source                = "../modules/aks"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg1.name
  service_principal_name = var.service_principal_name
  client_id             = module.ServicePrincipal.client_id
  client_secret         = module.ServicePrincipal.client_secret
  node_pool_name        = var.node_pool_name
  cluster_name          = var.cluster_name

  depends_on = [
    module.ServicePrincipal
  ]
  
}

resource "local_file" "kubeconfig" {
  content  = module.aks.config
  filename = "./${var.cluster_name}_kubeconfig"
  depends_on = [
    module.aks
  ]
  
}
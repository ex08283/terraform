resource "azurerm_resource_group" "rg1" {
  name = var.rgname
  location = var.allowed_locations[0]
  tags = var.resource_tags
}


module "aks" {
  source = "./modules/aks"
  location = var.allowed_locations[0]
  resource_group_name = var.rgname
}


resource "local_file" "kubeconfig" {
  depends_on = [ module.aks ]
  filename = "./kubeconfig"
  content = module.aks.config
}



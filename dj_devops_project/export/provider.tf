provider "azurerm" {
  features {
  }
  use_cli                         = true
  use_oidc                        = false
  resource_provider_registrations = "none"
  subscription_id                 = "f30f4f95-ede5-4f68-aa0c-811033ee0007"
  environment                     = "public"
  use_msi                         = false
}

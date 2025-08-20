provider "azurerm" {
  features {
  }
  resource_provider_registrations = "none"
  subscription_id                 = "8f2f2e98-2bdf-4cb7-a893-8a0e07a806d7"
  environment                     = "public"
  use_msi                         = false
  use_cli                         = true
  use_oidc                        = false
}

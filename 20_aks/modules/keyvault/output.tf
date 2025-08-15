#When you create resources inside a module, 
#sometimes you want to use some of their details outside the module.

#Example:
#Your keyvault module creates an Azure Key Vault.
#Later, in the root module, you need the Key Vault’s ID to create secrets.
#That Key Vault ID only exists inside the module — unless you expose it with an output.

output "keyvault_id" {
  value = azurerm_key_vault.kv.id
}   

output "keyvault_id" {
  value       = azurerm_key_vault.kv.id
  description = "The ID of the Key Vault"
}
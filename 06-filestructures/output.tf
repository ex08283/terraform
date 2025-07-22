# Output the storage account name
output "storage_account_name" {
  value = azurerm_storage_account.storageacc.name # Output the name of the storage account 
}

